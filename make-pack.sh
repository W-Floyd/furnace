#!/bin/bash

PS4='Line ${LINENO}: '

__sizes=''
__verbose='0'
__very_verbose_pack='0'
__install='0'
__mobile='0'
__quick='1'
__time='0'
__force='0'
__debug='0'
__silent='0'
__should_warn='0'
__use_custom_size='0'
__dry='0'
__compress='0'

__smelt_functions_bin='/usr/share/smelt/smelt_functions.sh'
__smelt_render_bin='/usr/share/smelt/smelt_render.sh'

# Print help
__usage () {
echo "$0 <OPTIONS> <SIZE>

Makes the resource pack at the specified size(s) (or using
default list of sizes). Order of options and size(s) are not
important.

Options:
  -h  --help  -?        This help message
  -v  --verbose         Be verbose
  -i  --install         Install or update .minecraft folder copy
  -m  --mobile          Make mobile resource pack as well
  -s  --slow            Use Inkscape instead of rsvg-convert
  -t  --time            Time functions (for debugging)
  -d  --debug           Use debugging mode
  -l  --lengthy         Very verbose debugging mode
  -f  --force           Discard pre-rendered data
  -q  --quiet           No output
  -w  --warn            Show warnings
  -c  --compress        Actually compress zip files\
"
}

# get functions from file
source "${__smelt_functions_bin}" &> /dev/null || { echo "Failed to load functions '${__smelt_functions_bin}'"; exit 1; }

__force_time "Rendered all" start

if ! [ -e 'config.sh' ]; then
    __warn "No config file was found, using default values"
else
    source 'config.sh' || __error "Config file has an error"
fi

# If there are are options,
if ! [ "${#}" = 0 ]; then

# then let's look at them in sequence.
while ! [ "${#}" = '0' ]; do

    __check_input () {

    case "${1}" in

        "h" | "--help" | "?")
            __usage
            exit 77
            ;;

        "v" | "--verbose")
            __verbose='1'
            __silent='0'
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

        "s" | "--slow")
            __quick='0'
            ;;

        "t" | "--time")
            __time='1'
            ;;

        "d" | "--debug")
            __debug='1'
            ;;

        "f" | "--force")
            __force='1'
            ;;

        "q" | "--quiet")
            __silent='1'
            __verbose='0'
            ;;

        "w" | "--warn")
            __should_warn='1'
            ;;

        "c" | "--compress")
            __compress='1'
            ;;

        "--dry")
            __dry='1'
            ;;

        [0-9]*)
            if [ -z "${__sizes}" ] || [ "${__use_custom_size}" = '1' ]; then
                __use_custom_size='1'
                __sizes="${__sizes}
${1}"
            else
                __warn "Overriding render sizes"
                __use_custom_size='1'
                __sizes="${1}"
            fi
            ;;

        *)
            __warn "Unknown option '${1}'"
            __usage
            exit 77
            ;;

    esac

    }

    if echo "${1}" | grep '^--' &> /dev/null; then

        __check_input "${1}"

    elif echo "${1}" | grep '^-' &> /dev/null; then

        for __letter in $(echo "${1}" | cut -c 2- | sed 's/./& /g'); do

            __check_input "${__letter}"

        done

    else
        __check_input "${1}"
    fi

    if [ "${?}" = '77' ]; then
        exit
    fi

    shift

done

fi

################################################################

# Location of catalogue file
if [ -z "${__catalogue}" ]; then
    __catalogue='catalogue.xml'
    if ! [ -e "${__catalogue}" ]; then
        __custom_error "Catalogue '${__catalogue}' is missing"
        exit 1
    fi
else
    if ! [ -e "${__catalogue}" ]; then
        __custom_error "Custom catalogue '${__catalogue}' is missing"
        exit 1
    fi
fi

if ! [ -d 'src' ]; then
    __custom_error "Source file directory 'src' is missing"
    exit 1
fi

################################################################

if [ -z "${__sizes}" ]; then
__sizes="32
64
128
256
512"
fi

__sizes="$(echo "${__sizes}" | sort -n | uniq)"

__render_and_pack () {

__force_announce "Processing size ${1}"

__options="${1}"

if [ "${__mobile}" = '1' ]; then
    __options="${__options} -m"
fi

if [ "${__quick}" = '0' ]; then
    __options="${__options} -s"
fi

if [ "${__time}" = '1' ]; then
    __options="${__options} -t"
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

if [ "${__dry}" = '1' ]; then
    __options="${__options} --dry"
fi

if [ "${__very_verbose_pack}" = '1' ]; then
    "${__smelt_render_bin}" ${__options} -l -p "${1}" || __error "Render encountered errors"
elif [ "${__verbose}" = '1' ]; then
    "${__smelt_render_bin}" ${__options} -v -p "${1}" || __error "Render encountered errors, please run with very verbose mode on"
else
    "${__smelt_render_bin}" ${__options} -p "${1}" || __error "Render encountered errors, please run with very verbose mode on"
fi

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

        zip -q -9 -r "../${2}" ./

    else

        zip -qZ store -r "../${2}" ./

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

__loop () {
for __size in ${__sizes}; do

    __packfile="$("${__smelt_render_bin}" --name-only "${__size}")"

    if ! [ "$?" = 0 ]; then
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

        if [ "${__silent}" = '0' ]; then
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

    if [ "${__install}" = '1' ]; then

    if [ -a "${__dest}" ] ; then
        rm "${__dest}"
    fi

    cp "${__packfile}.zip" "${__dest}"

    fi

    if [ "${__silent}" = '0' ] && [ "${__dry}" = '0' ] && [ "${__time}" = '0' ]; then
        echo
    fi

done
}

__loop

__force_time "Rendered all" end

exit
