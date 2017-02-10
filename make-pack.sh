#!/bin/bash

__sizes=''
__verbose='0'
__very_verbose_pack='0'
__install='0'
__mobile='0'
__quick='1'
__time='0'
__force='0'
__debug='0'

# Print help
__usage () {
echo "$0 <OPTIONS> <SIZE>

Makes the texture pack at the specified size(s) (or using
default list of sizes). Order of options and size(s) are not
important.

Options:
  -h  --help  -?        This help message
  -v  --verbose         Be verbose
  -vv --very-verbose    Be very verbose
  -i  --install         Install or update .minecraft folder copy
  -m  --mobile          Make mobile resource pack as well
  -s  --slow            Use Inkscape instead of rsvg-convert
  -t  --time            Time functions (for debugging)
  -d  --debug           Use debugging mode\
"
}

# get functions from file
source "$(which __smelt_functions)"

# If there are are options,
if ! [ "${#}" = 0 ]; then

# then let's look at them in sequence.
while ! [ "${#}" = '0' ]; do

    case "${1}" in

        "-h" | "--help" | "-?")
            __usage
            exit
            ;;

        "-v" | "--verbose")
            __verbose='1'
            ;;

        "-vv" | "--very-verbose")
            __verbose='1'
            __very_verbose_pack='1'
            ;;

        "-i" | "--install")
            __install='1'
            ;;

        "-m" | "--mobile")
            __mobile='1'
            ;;

        "-s" | "--slow")
            __quick='0'
            ;;

        "-t" | "--time")
            __time='1'
            ;;

        "-d" | "--debug")
            __debug='1'
            ;;

        "-f" | "--force")
            __force='1'
            ;;

        [0-9]*)
            __sizes="${__sizes}
${1}"
            ;;

        *)
            echo "Unknown option \"${1}\""
            echo
            __usage
            exit 1
            ;;

    esac

    shift

done

fi

if [ -z "${__sizes}" ]; then
__sizes="32
64
128
256
512"
fi

__render_and_pack () {

echo "Processing size ${1}"

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

if [ "${__very_verbose_pack}" = '1' ]; then
    __smelt_render ${__options} -v -p "${1}"
else
    __smelt_render ${__options} -p "${1}" &> /dev/null
fi

if [ -a "${2}.zip" ]; then
    rm "${2}.zip"
fi

if [ "${__mobile}" = '1' ] && [ -a "${2}_mobile.zip" ]; then
    rm "${2}_mobile.zip"
fi

__pushd "${2}_cleaned"

zip -qZ store -r "../${2}" ./

__popd

if [ "${__mobile}" = '1' ]; then
    __pushd "${2}_mobile"
    zip -qZ store -r "../${2}_mobile" ./
    __popd
fi

if [ -d "${2}_cleaned" ]; then
    rm -r "${2}_cleaned"
fi

if [ -d "${2}_mobile" ]; then
    rm -r "${2}_mobile"
fi

}

__loop () {
for __size in ${__sizes}; do

    __packfile="$(__smelt_render --name-only "${__size}")"

    if [ "${__time}" = '1' ]; then

        echo
        echo
        time __render_and_pack "${__size}" "${__packfile}"

    else

        __render_and_pack "${__size}" "${__packfile}"

    fi

    __dest="${HOME}/.minecraft/resourcepacks/${__packfile}.zip"

    if [ "${__install}" = '1' ]; then

    if [ -a "${__dest}" ] ; then
        rm "${__dest}"
    fi

    cp "${__packfile}.zip" "${__dest}"

    fi

done
}

__time "Rendered" start

if [ "${__verbose}" = '1' ]; then

    __loop

else

    __loop # &> /dev/null

fi

__time "Rendered" end

exit
