#!/bin/bash

if ! which neato &> /dev/null; then
    __error "\"neato\" could not be found, please install the graphviz package"
fi

__graph_tmp_dir="/tmp/smelt/graph${__pid}"
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
    sep="0.3";
    node [style=filled, shape=record];' > "${__graph}"

__pushd './src/xml/tmp_deps/'

if [ "${__use_files}" = '1' ]; then

while read -r __item; do
    if ! [ -e "${__item}" ]; then
        __force_warn "Item \"${__item}\" does not exist"
    else
        __dep_list="$(cat "${__item}")
${__dep_list}"
    fi
done <<< "${__files}"

fi

__popd

__dep_list="${__files}
${__dep_list}"

__dep_list="$(echo "${__dep_list}" | grep -v '^$')"

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

        if ! [ -z "$(echo "${__name}" | grep -F "${__dep_list}")" ]; then
            __tmp_func
        fi

    else

        if [ "$(__get_value "${__graph_tmp_dir}/readrangetmp" KEEP)" = 'YES' ]; then
            __tmp_func
        fi

    fi

done

echo '}' >> "${__graph}"

cat "${__graph}" | neato -T${1} -o "${__output}"

rm -r "${__graph_tmp_dir}"

exit
