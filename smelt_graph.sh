#!/bin/bash

if ! which neato &> /dev/null; then
    __error "\"neato\" could not be found, please install the graphviz package"
fi

__graph_tmp_dir="/tmp/smelt/graph${$}"
mkdir -p "${__graph_tmp_dir}"

__output="${4}.${1}"

__catalogue="${2}"

__graph="${__graph_tmp_dir}/graph"

if ! [ -z "${3}" ]; then
    __files="${3}"
fi

if [ -z "${__files}" ]; then
    __use_files='0'
else
    __use_files='1'
fi

__dep_list=''

echo \
'digraph pack {
    overlap=scalexy;
    splines=true;
    sep="0.3";' > "${__graph}"

__list="$(cat './src/xml/list')"

__pushd './src/xml/tmp_deps/'

if [ "${__use_files}" = '1' ]; then

    while read -r __item; do
        if ! grep -xq "${__item}" <<< "${__list}"; then
            __force_warn "Item \"${__item}\" does not exist"
        else
            __matches="$(grep -x "${__item}" <<< "${__list}")"
            while read -r __match; do
                __dep_list="$(cat "${__match}")
${__dep_list}"
            done <<< "${__matches}"
        fi
    done <<< "${__files}"

fi

echo '    node [style=filled, shape=record, color="black" fillcolor="lightgray" ];' >> "${__graph}"

if [ "${__use_files}" = '1' ]; then
    echo "${__dep_list}" | grep -v "${__files}" | grep -v '^$' | sed 's/.*/    "&";/' >> "${__graph}"
fi

__dep_list="$(grep -x "${__files}" <<< "${__list}")
${__dep_list}"

if [ "${__use_files}" = '1' ]; then
    echo '    node [style=filled, shape=record, color="blue" fillcolor="lightblue"];
    ' >> "${__graph}"
fi

__popd

if ! [ -z "${__dep_list}" ]; then

    __dep_list="$(echo "${__dep_list}" | grep -v '^$' | sort | uniq)"

    echo "${__dep_list}" > "${__graph_tmp_dir}/dep_list"

    __tmp_func () {

    __deps="$({ __get_value "${__graph_tmp_dir}/readrangetmp" DEPENDS; __get_value "${__graph_tmp_dir}/readrangetmp" CONFIG | __stdconf; __get_value "${__graph_tmp_dir}/readrangetmp" CLEANUP; } | sed '/^$/d')"

    if ! [ -z "${__deps}" ]; then

        while read -r __dep; do
            if ! [ "${__dep}" = "${__name}" ]; then
                echo "    \"${__dep}\" -> \"${__name}\";"
            fi
        done <<< "${__deps}" | sort | uniq >> "${__graph}"

    fi

    }

    for __range in $(__get_range "${__catalogue}" ITEM); do

        __read_range "${__catalogue}" "${__range}" > "${__graph_tmp_dir}/readrangetmp"

        __name="$(__get_value "${__graph_tmp_dir}/readrangetmp" NAME)"

        if [ "${__use_files}" = '1' ]; then

            if echo "${__name}" | grep -Fxq "${__dep_list}"; then
                __tmp_func
            fi

        else

            if [ "$(__get_value "${__graph_tmp_dir}/readrangetmp" KEEP)" = 'YES' ]; then
                __tmp_func
            fi

        fi

    done

    echo '}' >> "${__graph}"

    neato "-T${1}" -o "${__output}" < "${__graph}"

else

    __custom_error "No valid items specified."

fi

# rm -r "${__graph_tmp_dir}"

exit
