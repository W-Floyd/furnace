################################################################################
# Hashing Functions
################################################################################

################################################################################
#
# In all cases:
# ... | __hash_<ENGINE> <INPUTS>
#
# <ENGINE> Hash
# Hashes files. Meant to be gnu tools, that all follow the same formatting.
#
################################################################################

__routine__hash__md5sum () {
if read -r -t 0; then
    cat | md5sum "${@}"
else
    md5sum "${@}"
fi

}

__routine__hash__sha1sum () {
if read -r -t 0; then
    cat | sha1sum "${@}"
else
    sha1sum "${@}"
fi

}

__routine__hash__sha224sum () {
if read -r -t 0; then
    cat | sha224sum "${@}"
else
    sha224sum "${@}"
fi

}

__routine__hash__sha256sum () {
if read -r -t 0; then
    cat | sha256sum "${@}"
else
    sha256sum "${@}"
fi

}

__routine__hash__sha384sum () {
if read -r -t 0; then
    cat | sha384sum "${@}"
else
    sha384sum "${@}"
fi

}

__routine__hash__sha512sum () {
if read -r -t 0; then
    cat | sha512sum "${@}"
else
    sha512sum "${@}"
fi

}

################################################################################
#
# __hash <INPUTS>
#
# Hash
# Hash file, so that testing different programs can be done easily.
# Assumes it has already had it's routine chosen (in setup most likely)
#
################################################################################

__hash () {

__debug_toggle off

"${__function_hash}" "${@}"

__debug_toggle on

}

################################################################################
#
# ... | __hash_piped
#
# Hash Piped
# Hash piped input, so that testing different programs can be done easily.
#
################################################################################

__hash_piped () {

__debug_toggle off

cat | "${__function_hash}" "${@}"

__debug_toggle on

}

################################################################################
#
# __hash_folder <FILE> <EXCLUDEDIR>
#
# Hashes the current folder and outputs to <FILE>.
# EXCLUDEDIR is optional (in the form of "xml", not "./xml/").
#
################################################################################

__hash_folder () {
if [ -z "${2}" ]; then
    local __listing="$(find . -type l; find . -type f)"
else
    local __listing="$(find . -not -path "./${2}/*" -type f; find . -not -path "./${2}/*" -type l)"
fi

if ! [ -z "${__listing}" ]; then

    {

    __hash $(grep -v ' ' <<< "${__listing}" | tr '\n' ' ') >> "${1}"

    grep ' ' <<< "${__listing}" | sed '/^$/d' | while read -r __file; do
        __hash "${__file}"
    done

    } > "${1}"
fi

}

################################################################################
#
# __check_hash_folder <FILE> <OUTPUT>
#
# Hashes the current folder and compares to <FILE>, outputting to <OUTPUT>.
#
################################################################################

__check_hash_folder () {
__hash -c "${1}" > "${2}"
}
