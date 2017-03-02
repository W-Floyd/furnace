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
__clean_xml='0'
__do_not_render='0'
__list_completed='0'
__list_changed='0'
__last_size='0'

export __smelt_functions_bin='/usr/share/smelt/smelt_functions.sh'
export __smelt_image_functions_bin='/usr/share/smelt/smelt_image_functions.sh'
export __smelt_render_bin='/usr/share/smelt/smelt_render.sh'
export __smelt_completed_bin='/usr/share/smelt/smelt_completed.sh'
export __catalogue='catalogue.xml'

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
  -c  --compress        Actually compress zip files
  -x  --force-xml       Force resplitting of xml files
      --completed       List completed textures, according to
                        the COMMON field in the catalogue.
      --changed         List ITEMS changed since last render.\
"
}

################################################################

# get functions from file
source "${__smelt_functions_bin}" &> /dev/null || { echo "Failed to load functions \"${__smelt_functions_bin}\""; exit 1; }

################################################################

if ! [ -e 'config.sh' ]; then
    __force_warn "No config file was found, using default values"
else
    if [ "$(head -n 1 'config.sh')" = '#smeltconfig#' ]; then
        source 'config.sh' || __error "Config file has an error"
    else
        __error "Config does not have correct header \"#smeltconfig#\""
    fi
fi

################################################################

__force_time "Rendered all" start

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

        "x" | "--force-xml")
            __force_warn "Cleaning split xml files"
            __clean_xml='1'
            ;;

        "--dry")
            __dry='1'
            ;;

        "--completed")
            __list_completed='1'
            ;;

        "--changed")
            __list_changed='1'
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
            __warn "Unknown option \"${1}\""
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

if ! [ -d './src' ] && ! [ -e "${__catalogue}" ]; then
    __error "Not a resource pack project folder"
elif ! [ -e "${__catalogue}" ]; then
    __error "Catalogue \"${__catalogue}\" is missing"
elif ! [ -d 'src' ]; then
    __error "Source file directory \"src\" is missing"
fi

if [ "${__list_completed}" = '1' ]; then
    "${__smelt_completed_bin}" "${__catalogue}"
    exit
fi

if [ "${__clean_xml}" = '1' ] && [ -d './src/xml/' ]; then
    rm -r './src/xml/'
fi

################################################################

if [ -z "${__sizes}" ]; then
__sizes="32
64
128
256
512"
fi

__final_size="$(tr ' ' '\n' <<< "${__sizes}" | tail -n1)"

__sizes="$(echo "${__sizes}" | sort -n | uniq)"

__just_render () {

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

if [ "${__do_not_render}" = '1' ]; then
    __options="${__options} --do-not-render"
fi

if [ "${__very_verbose_pack}" = '1' ]; then
    "${__smelt_render_bin}" ${__options} -l -p "${1}" || __error "Render encountered errors"
elif [ "${__verbose}" = '1' ]; then
    "${__smelt_render_bin}" ${__options} -v -p "${1}" || __error "Render encountered errors, please run with very verbose mode on"
else
    "${__smelt_render_bin}" ${__options} -p "${1}" || __error "Render encountered errors, please run with very verbose mode on"
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

if [ "${__install}" = '1' ]; then

    if [ -e "${__dest}" ] ; then
        rm "${__dest}"
    fi

    cp "${__packfile}.zip" "${__dest}"

fi

if [ "${__silent}" = '0' ] && [ "${__dry}" = '0' ] && [ "${__time}" = '0' ] && ! [ "${__size}" = "${__final_size}" ]; then
    echo
fi

}

for __size in ${__sizes}; do
    if [ "${__size}" = "${__final_size}" ]; then
        __last_size='1'
    fi

    if [ "${__list_changed}" = '1' ]; then
        "${__smelt_render_bin}" --list-changed "${__size}"
        if [ "${__last_size}" = '0' ]; then
            echo
        fi
    else
        __sub_loop "${__size}"
    fi
done

__force_time "Rendered all" end

exit
