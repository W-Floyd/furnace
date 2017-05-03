#!/bin/bash

__sizes=''
__verbose='0'
__very_verbose_pack='0'
__install='0'
__mobile='0'
__time='0'
__benchmark='0'
__force='0'
__render_optional='0'
__debug='0'
__quiet='0'
__silent='0'
__should_warn='0'
__use_custom_size='0'
__dry='0'
__compress='0'
__clean_xml='0'
__xml_only='0'
__do_not_render='0'
__list_completed='0'
__graph_deps='0'
__no_highlight='0'
__list_changed='0'
__last_size='0'
__should_optimize='0'
__no_optimize='0'
__ignore_max_optimize='0'
__ignore_max_optional='0'
__re_optimize='0'
__show_progress='1'
__use_optional_size='0'
__max_install_size='1024'
__short_output='0'

export __run_dir="$(dirname "$(readlink -f "${0}")")"
export __furnace_setup_bin="${__run_dir}/furnace_setup.sh"

# get set up
source "${__furnace_setup_bin}" 1> /dev/null || { echo "Failed to load setup \"${__furnace_setup_bin}\""; exit 1; }

# Print help
__usage_short () {
echo "$(basename "${0}") <OPTIONS> <SIZE>

Makes the resource pack at the specified size(s) (or using default list of
sizes). Order of options and size(s) are not important, other than options which
take secondary inputs.

Options:
  -h  -?                    Short help (this message).
      --help                Long help.
  -v  --verbose             Be verbose.
  -i  --install             Install to ~/.minecraft folder.
  -f  --force-render        Discard pre-rendered data.
  -q  --quiet               Just show progress report.
      --silent              No output at all.
      --short               Use short output format.
  -w  --warn                Show warnings.
  -c  --compress            Actually compress zip files.
  -o  --optimize            Optimize final PNG files.
      --no-optimize         Do not optimize final PNG files.
  --optional <SIZE>         Render optional items, optionally at specified size
                            only. Use - to ignore the specification.
  --graph <ITEM>            Render a graph of the dependency tree. Optional
                            input is list of ITEMs to be the subject of the
                            graph. May be specified multiple times."
}

__usage () {
echo "$(basename "${0}") <OPTIONS> <SIZE>

Makes the resource pack at the specified size(s) (or using
default list of sizes). Order of options and size(s) are not
important, other than options which take secondary inputs.

General Options:
  -h  -?                    Short help.
      --help                Long help (this message).

  -v  --verbose             Be verbose.
  -q  --quiet               Just progress report.
      --silent              No output at all.
      --no-progress         Do not show a progress report.
      --short               Use short output format.

  -i  --install             Install to ~/.minecraft folder.
  -t  --time                Time functions.
  -b  --benchmark           Log times for each texture, for each size rendered.
  -d  --debug               Use debugging mode.
  -l  --lengthy             Very verbose debugging mode.
  -w  --warn                Show warnings.
  -c  --compress            Actually compress zip files.

Render Options:
  -f  --force-render        Discard pre-rendered data.
  -m  --mobile              Make mobile resource pack as well.

  -o  --optimize            Optimize final PNG files.
      --no-optimize         Do not optimize final PNG files.
      --re-optimize         Re-process and re-optimize files appropriately.

  --max-optimize <SIZE>     Max size to optimize.
  --force-optimize          Optimize any size of final PNG files.
  --force-max-optimize      Ensure max-optimize is obeyed.

  --optimizer <OPTIMIZER>   Optimize with specified optimizer.

  --optional <SIZE>         Render optional items, optionally at specified size
                            only. Use - to ignore the specification.
  --max-optional <SIZE>     Maximum size to render optional size.
  --no-optional             Do not render any optional items.

  --name <NAME>             Name to use when processing a pack.

Graphing Options:
  --graph <ITEM>            Render a graph of the dependency tree. Optional
                            input is a comma and/or new-line separated list of
                            ITEMs to be the subject of the graph For a full
                            graph, use '', '.*', or nothing. May be specified
                            multiple times. Supports regex.
  --graph-format <FORMAT>   Specifies the format to graph to. Defaults to png.
  --graph-seed <SEED>       Seed to use when graphing. Defaults to a random seed
                            when unspecified.
  --grapher <GRAPHER>       Graphviz tool to use when graphing. Defaults to
                            neato.
  --graph-output <NAME>     Name to use when outputting a graph. Default output
                            is 'graph'
  --no-highlight            Do not highlight specified files when graphing.

Other Options:
  --completed               List completed textures, according to the COMMON
                            field in the catalogue

  --changed                 List ITEMS changed since last render

  -x  --force-xml           Force re-splitting of xml files
      --xml-only            Only split xml files"
}

################################################################################

__force_time "Rendered all" start
__force_time "Processed XML" start

# If there are are options,
if ! [ "${#}" = 0 ]; then

################################################################################

__check_input () {

case "${1}" in

    "h" |"?")
        __usage_short
        exit 77
        ;;

    "--help")
        __usage
        exit 77
        ;;

    "--no-progress")
        __show_progress='0'
        ;;

    "--short")
        __short_output='1'
        ;;

    "v" | "--verbose")
        __verbose='1'
        __quiet='0'
        ;;

    "l" | "--lengthy")
        __verbose='1'
        __very_verbose_pack='1'
        ;;

    "i" | "--install")
        __install='1'
        ;;

    "m" | "--mobile")
        __mobile='1'
        ;;

    "t" | "--time")
        __time='1'
        ;;

    "b" | "--benchmark")
        __announce "Benchmarking mode enabled"
        __benchmark='1'
        ;;

    "d" | "--debug")
        __debug='1'
        ;;

    "f" | "--force-render")
        __force='1'
        ;;

    "--optional")
        __render_optional='1'
        ;;

    "--no-optional")
        __render_optional='0'
        ;;

    "--max-optional")
        ;;

    "--force-optional")
        __render_optional='1'
        __ignore_max_optional='1'
        ;;

    "q" | "--quiet")
        __quiet='1'
        __verbose='0'
        ;;

    "--silent")
        __silent='1'
        __quiet='1'
        ;;

    "w" | "--warn")
        __should_warn='1'
        ;;

    "c" | "--compress")
        __compress='1'
        ;;

    "x" | "--force-xml")
        __force_warn "Cleaning split xml files"
        __clean_xml='1'
        ;;

    "--xml-only")
        __xml_only='1'
        ;;

    "o" | "--optimize")
        __should_optimize='1'
        ;;

    "--dry")
        __dry='1'
        ;;

    "--completed")
        __list_completed='1'
        ;;

    "--graph")
        __graph_deps='1'
        ;;

    "--graph-format")
        __graph_deps='1'
        ;;

    "--graph-output")
        __graph_deps='1'
        ;;

    "--grapher")
        __graph_deps='1'
        ;;

    "--graph-seed")
        __graph_deps='1'
        ;;

    "--no-highlight")
        __no_highlight='1'
        ;;

    "--changed")
        __list_changed='1'
        ;;

    "--no-optimize")
        __no_optimize='1'
        ;;

    "--max-optimize")
        ;;

    "--force-max-optimize")
        __ignore_max_optimize='0'
        ;;

    "--force-optimize")
        __should_optimize='1'
        __ignore_max_optimize='1'
        ;;

    "--re-optimize")
        __re_optimize='1'
        ;;

    "--optimizer")
        ;;

    "--name")
        ;;

    [0-9]*)
        if [ "${__use_custom_size}" = '0' ]; then
            __warn "Overriding render sizes"
            __use_custom_size='1'
            __sizes=''
        fi

        if [ "${1}" -gt '0' ]; then
            __sizes="${__sizes}
${1}"
        else
            __force_warn "Specified size \"${1}\" is less than 1, cannot render"
            __use_custom_size='1'
        fi
        ;;

    *)
        __custom_error "Unknown option \"${1}\""
        __usage_short
        exit 77
        ;;

esac

}

################################################################################

__process_option () {

if [ "${1}" = '-' ] || [ "${1}" = '--' ]; then

    __check_input "${1}"

elif echo "${1}" | grep '^--.*' &> /dev/null; then

    __check_input "${1}"

elif echo "${1}" | grep '^-.*' &> /dev/null; then

    __letters="$(echo "${1}" | cut -c 2- | sed 's/./& /g')"

    for __letter in ${__letters}; do

        if [[ "${__letter}" == [0-9] ]]; then

            __force_warn "Sizes are not to be specified in this way"

        else

            __check_input "${__letter}"

        fi

    done

else
    __check_input "${1}"
fi

if [ "${?}" = '77' ]; then
    exit
fi

}

################################################################################

__check_option () {
if grep -q '^-.*' <<< "${1}"; then
    return 0
else
    return 1
fi
}

################################################################################

# then let's look at them in sequence.
while ! [ "${#}" = '0' ]; do

    case "${__last_option}" in

        "--max-optimize")
            if [ "${1}" -eq "${1}" ] 2>/dev/null; then
                __max_optimize="${1}"
            else
                __error "Given input is not a size"
            fi
            ;;

        "--optimizer")
            if __test_function 'optimize' "${1}"; then
                __function_optimizer="${1}"
            else
                __error "Given input is not a valid optimizer"
            fi
            ;;

        "--name")
            if __check_option "${1}"; then
                __force_warn "Given name may actually be an option."
            fi
            __name="${1}"
            ;;

        "--graph")
            if __check_option "${1}"; then
                __process_option "${1}"
            elif [[  "${1}" == [0-9]* ]]; then
                __force_warn "Size is not important when graphing, and will be ignored"
            else
                if [ -z "${__graph_files}" ]; then
                    __graph_files="$(echo "${1}" | tr ',' '\n')"
                else
                    __graph_files="${__graph_files}
$(echo "${1}" | tr ',' '\n')"
                fi
            fi
            ;;

        "--graph-format")
            __graph_format="${1}"
            ;;

        "--graph-output")
            __graph_output="${1}"
            ;;

        "--grapher")
            __grapher="${1}"
            ;;

        "--graph-seed")
            __graph_seed="${1}"
            ;;

        "--optional")
            if ! [ "${1}" = '-' ]; then
                if [ "${1}" -eq "${1}" ] 2>/dev/null; then
                    __use_optional_size='1'
                    __optional_size="${1}"
                elif __check_option "${1}"; then
                    __process_option "${1}"
                else
                    __error "Given input is not a size"
                fi
            fi
            ;;

        "--max-optional")
            if [ "${1}" -eq "${1}" ] 2>/dev/null; then
                __max_optional="${1}"
            else
                __error "Given input is not a size"
            fi
            ;;

        *)
            __process_option "${1}"
            ;;

    esac

    __last_option="${1}"

    shift

done

fi

__last_option=''

################################################################################

if ! [ -d './src' ] && ! [ -e "${__catalogue}" ]; then
    __error "Not a resource pack project folder"
elif ! [ -e "${__catalogue}" ]; then
    __error "Catalogue \"${__catalogue}\" is missing"
elif ! [ -d 'src' ]; then
    __error "Source file directory \"src\" is missing"
fi

# set pack name if not set already
if [ -z "${__name}" ]; then
    __name="$(basename "${__working_dir}")"
    __force_warn "Pack name not defined, defaulting to ${__name}"
fi

if [ "${__list_completed}" = '1' ]; then
    "${__furnace_completed_bin}" "${__catalogue}"
    exit
fi

if [ "${__graph_deps}" = '1' ]; then
    "${__furnace_render_bin}" --xml-only 1> /dev/null

    if [ -z "${__graph_files}" ]; then
        __graph_files=''
    fi

    if [ -z "${__graph_format}" ]; then
        __graph_format='png'
    fi

    if [ -z "${__graph_output}" ]; then
        __graph_output='graph'
    fi

    if [ -z "${__grapher}" ]; then
        __grapher='neato'
    fi

    if [ -z "${__graph_seed}" ]; then
        __graph_seed="${RANDOM}"
        __force_announce "Using seed \"${__graph_seed}\"."
    fi

    export __debug

    "${__furnace_graph_bin}" "${__graph_format}" "${__catalogue}" "${__graph_files}" "${__graph_output}" "${__grapher}" "${__graph_seed}" "${__no_highlight}"
    exit 0
fi

if [ "${__clean_xml}" = '1' ] && [ -d './src/xml/' ]; then
    rm -r './src/xml/'
fi

################################################################################

if [ "${__use_custom_size}" = '0' ] && [ -z "${__sizes}" ]; then
__sizes="32
64
128
256
512
1024"
fi

if [ -z "${__sizes}" ]; then
    __error "No valid sizes to render"
fi

__final_size="$(tr ' ' '\n' <<< "${__sizes}" | tail -n1)"

__sizes="$(echo "${__sizes}" | tr ' ' '\n' | sort -n | uniq)"

if [ -z "${__max_optimize}" ]; then
    __default_max_optimize='512'
    __max_optimize="${__default_max_optimize}"
    if [ "${__should_optimize}" = '1' ] ; then
        __should_warn_size='0'
        while read -r __test_size; do
            if ! [ "${__test_size}" -lt "${__default_max_optimize}" ]; then
                __should_warn_size='1'
                break
            fi
        done <<< "${__sizes}"
        if [ "${__should_warn_size}" = '1' ]; then
            __force_warn "Default maximum optimization size is \"${__default_max_optimize}\",
some sizes will not be optimized. Use --force-optimize to override this, or set
a new maximum with --max-optimize <SIZE>"
        fi
    fi
fi

if [ -z "${__max_optional}" ]; then
    __default_max_optional='2048'
    __max_optional="${__default_max_optional}"
    if [ "${__render_optional}" = '1' ] ; then
        __should_warn_size='0'
        while read -r __test_size; do
            if ! [ "${__test_size}" -lt "${__default_max_optional}" ]; then
                __should_warn_size='1'
                break
            fi
        done <<< "${__sizes}"
        if [ "${__should_warn_size}" = '1' ]; then
            __force_warn "Default maximum optional size is \"${__default_max_optional}\",
some sizes will not have optional images rendered. Use --force-optional to
override this, or set a new maximum with --max-optional <SIZE>"
        fi
    fi
fi

__just_render () {

__options="${1}"

if [ "${__mobile}" = '1' ]; then
    __options="${__options} -m"
fi

if [ "${__time}" = '1' ]; then
    __options="${__options} -t"
fi

if [ "${__benchmark}" = '1' ]; then
    __options="${__options} -b"
fi

if [ "${__debug}" = '1' ]; then
    __options="${__options} -d"
fi

if [ "${__force}" = '1' ]; then
    __options="${__options} -f"
fi

if [ "${__should_warn}" = '1' ]; then
    __options="${__options} -w"
fi

if [ "${__should_optimize}" = '1' ]; then
    __options="${__options} -o"
fi

if [ "${__show_progress}" = '1' ]; then
    __options="${__options} --progress"
fi

if [ "${__list_changed}" = '1' ]; then
    __options="${__options} --list-changed"
fi

if [ "${__xml_only}" = '1' ]; then
    __options="${__options} --xml-only"
fi

if [ "${__quiet}" = '1' ]; then
        __options="${__options} --quiet"
fi

if [ "${__no_optimize}" = '1' ] || [ "${__ignore_max_optimize}" = '0' -a "${1}" -gt "${__max_optimize}" ]; then
    __options="${__options} --no-optimize"
fi

if [ "${__re_optimize}" = '1' ] && [ "${__should_optimize}" = '1' ]; then
    __options="${__options} --re-optimize"
fi

if [ "${__dry}" = '1' ]; then
    __options="${__options} --dry"
fi

if [ "${__do_not_render}" = '1' ]; then
    __options="${__options} --do-not-render"
fi

if [ "${__short_output}" = '1' ]; then
    __options="${__options} --short"
fi

if [ "${__render_optional}" = '1' ]; then

    if [ "${__use_optional_size}" = '1' ]; then

        if [ "${__optional_size}" = "${1}" ]; then

            __options="${__options} --optional"

        fi

    elif ! [ "${1}" -gt "${__max_optional}" ] || [ "${__ignore_max_optional}" = '1' ]; then

        __options="${__options} --optional"

    fi

fi

if [ "${__very_verbose_pack}" = '1' ]; then
    "${__furnace_render_bin}" ${__options} -l -p "${1}" || __error "Render encountered errors"
elif [ "${__verbose}" = '1' ]; then
    "${__furnace_render_bin}" ${__options} -v -p "${1}" || __error "Render encountered errors, please run with very verbose mode on"
else
    "${__furnace_render_bin}" ${__options} -p "${1}" || __error "Render encountered errors, please run with very verbose mode on"
fi

if [ -e "./src/xml/loopstatus" ]; then

    __loop_status="$(cat "./src/xml/loopstatus")"
    rm "./src/xml/loopstatus"

else

    __loop_status='0'

fi

}

__render_and_pack () {

__force_announce "Processing \"${1}\""

__just_render "${1}"

if [ "${__dry}" = '0' ]; then


if [ -a "${2}.zip" ]; then
    rm "${2}.zip"
fi

if [ "${__mobile}" = '1' ] && [ -a "${2}_mobile.zip" ]; then
    rm "${2}_mobile.zip"
fi

__pushd "${2}_cleaned"

if [ "${__compress}" = '1' ]; then

    __force_announce "Compressing resource pack"

    zip -q -9 -r "../${2}" ./

else

    zip -qZ store -r "../${2}" ./

fi

__popd

if [ "${__mobile}" = '1' ]; then
    __pushd "${2}_mobile"

    if [ "${__compress}" = '1' ]; then

        zip -q -9 -r "../${2}_mobile" ./

    else

        zip -qZ store -r "../${2}_mobile" ./

    fi

    __popd
fi

if [ -d "${2}_cleaned" ]; then
    rm -r "${2}_cleaned"
fi

if [ -d "${2}_mobile" ]; then
    rm -r "${2}_mobile"
fi

fi

}

__sub_loop () {

__size="${1}"

__packfile="$("${__furnace_render_bin}" --name-only "${__size}")"

if ! [ "${?}" = 0 ]; then
    echo "${__packfile}"
    exit 1
fi

if [ "${__time}" = '1' ]; then

    __force_time "Rendered size ${__size}" start

    if [ "${__silent}" = '1' ]; then
        __render_and_pack "${__size}" "${__packfile}" 1> /dev/null
    else
        __render_and_pack "${__size}" "${__packfile}"
    fi

    __force_time "Rendered size ${__size}" end

    if [ "${__silent}" = '0' ] && ! [ "${__size}" = "${__final_size}" ]; then
        echo
    fi

else

    if [ "${__silent}" = '1' ]; then
        __render_and_pack "${__size}" "${__packfile}" 1> /dev/null
    else
        __render_and_pack "${__size}" "${__packfile}"
    fi

fi

__dest="${HOME}/.minecraft/resourcepacks/${__packfile}.zip"

if [ "${__install}" = '1' ] && ! [ "${__size}" -gt "${__max_install_size}" ]; then

    if [ -d "$(dirname "${__dest}")" ]; then

        if [ -e "${__dest}" ] ; then
            rm "${__dest}"
        fi

        cp "${__packfile}.zip" "${__dest}"

    else

        __force_warn "Minecraft does not seem to be installed, I won't try to install"

        __install='0'

    fi

fi

if [ "${__quiet}" = '0' ] && [ "${__dry}" = '0' ] && [ "${__time}" = '0' ] && ! [ "${__size}" = "${__final_size}" ]; then
    echo
fi

}

if ! [ -z "${__optimizer}" ] && [ "${__should_optimize}" = '1' ] && [ "${__verbose}" = '1' ]; then
    __announce "Using optimizer \"${__optimizer}\""
    echo
fi

if [ "${__xml_only}" = '1' ]; then
    __just_render 32
else

    for __size in ${__sizes}; do
        if [ "${__size}" = "${__final_size}" ]; then
            __last_size='1'
        else
            __last_size='0'
        fi

        if [ "${__list_changed}" = '1' ]; then

            __just_render "${__size}"

            if [ "${__last_size}" = '0' ]; then

                echo

            fi

        else

            if [ "${__size}" -gt "${__max_optimize}" ] && [ "${__ignore_max_optimize}" = '0' ] && [ "${__should_optimize}" = '1' ]; then

                if [ "${__verbose}" = '1' ]; then

                    __force_announce "Size \"${__size}\" is larger than the max optimize size \"${__max_optimize}\", not optimizing."

                fi

            fi

            __sub_loop "${__size}"

        fi

        if [ "${__loop_status}" = '1' ]; then
            exit
        fi

    done
fi

if [ "${__xml_only}" = '0' ]; then
    __force_time "Rendered all" end
else
    __force_time "Processed XML" end
fi

exit
