################################################################################
# General Functions
################################################################################

################################################################################
#
# <LIST_OF_FILES> | __mext <FILE_1> <FILE_2> <FILE_3> ...
#
# Minus Extension
# Strips last file extension from string.
#
################################################################################

__mext () {

__tmp_mext_sub () {
    echo "${1%.*}"
}

while ! [ "${#}" = '0' ]; do
    __tmp_mext_sub "${1}"
    shift
done

if read -r -t 0; then
    cat | while read -r __value; do
        __tmp_mext_sub "${__value}"
    done
fi

}

################################################################################
#
# <LIST_OF_FILES> | __oext <FILE_1> <FILE_2> <FILE_3> ...
#
# Only Extension
# Returns the final extension of a filename.
# Opposite of __mext.
#
################################################################################

__oext () {

__tmp_oext_sub () {
    echo "${1/*.}"
}

while ! [ "${#}" = '0' ]; do
    __tmp_oext_sub "${1}"
    shift
done

if read -r -t 0; then
    cat | while read -r __value; do
        __tmp_oext_sub "${__value}"
    done
fi

}

################################################################################
#
# __lsdir <DIR>
#
# List directories
# Lists all directories in the current folder, or specified folder.
#
################################################################################

__lsdir () {
if [ -z "${1}" ]; then
    find . -maxdepth 1 -mindepth 1 -type d | sort
else
    find "${1}" -maxdepth 1 -mindepth 1 -type d | sort
fi
}

################################################################################
#
# __empdir
#
# Remove Empty Directories
# Finds all empty directories, until no changes occur.
#
################################################################################

__empdir () {

__listing="$(find . | sort)"

__tmp_empdir_sub () {

find . -type d | while read -r __dir; do
    if ! [ "$(ls -A "${__dir}/")" ]; then
        rmdir "${__dir}"
    fi
done

}

__tmp_empdir_sub

__new_listing="$(find .)"

until [ "${__listing}" = "${__new_listing}" ]; do
    __listing="${__new_listing}"
    __new_listing="$(find . | sort)"
    __tmp_empdir_sub
done

}

################################################################################
#
# __emergency_exit
#
# Prints the last known command and exits, to be used when a command fails.
#
# Example:
# foobar --baz || __emergency_exit
#
################################################################################

__emergency_exit () {
echo "Last command run was ["!!"]"
exit 1
}



################################################################################
#
# __pushd <DIR>
#
# Same as regular pushd, just quiet unless told not to be.
#
################################################################################

__pushd () {
if [ -d "${1}" ]; then
    pushd "${1}" 1> /dev/null
else
    echo "Directory \"${1}\" does not exist!"
    exit 2
fi
}

################################################################################
#
# __popd
#
# Same as regular popd, just quiet unless told not to be.
#
################################################################################

__popd () {
popd 1> /dev/null
}

################################################################################
#
# __log2 <NUMBER>
#
# Log base 2
# Finds the log2 of a number, or rounds up to the next power of 2.
#
# Shamelessly stolen from:
# https://bobcopeland.com/blog/2010/09/log2-in-bash/
#
################################################################################

__log2 () {
local x=0
for (( y=$1-1 ; $y > 0; y >>= 1 )) ; do
    let x=$x+1
done
echo $x
}

################################################################################
#
# ... | __strip_zero
#
# Strip Zero
# From pipe, strips trailing zeros and dangling decimal place.
#
################################################################################

__strip_zero () {
cat | sed -e 's/\([^0]*\)0*$/\1/' -e 's/\.$//'
}

################################################################################
#
# ... | __funiq
#
# First uniq
# like uniq, but does not need to be sorted, and so retains ordering.
#
################################################################################

__funiq () {

cat | sed '/^$/d' | awk '!cnts[$0]++'

}

################################################################################
#
# __debug_toggle <on/off>
#
# Debug Toggle
# To be used in functions that do not need debugging (especially
# __choose_function) be sure to turn it back on when you're done!
#
################################################################################

__debug_toggle () {
set +x
if [ "${__very_verbose}" = '1' ] ; then
    if [ "${1}" = 'on' ]; then
        set -x
    elif ! [ "${1}" = 'off' ]; then
        set -x
        __force_warn "Invalid option \"${1}\" passed to __debug_toggle"
    fi
fi
}
