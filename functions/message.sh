################################################################################
# Message Functions
################################################################################

################################################################################
#
# __strip_ansi
#
# Strips ANSI codes from *piped* input.
#
################################################################################

__strip_ansi () {
cat | perl -pe 's/\e\[?.*?[\@-~]//g'
}

################################################################################
#
# __print_pad
#
# Prints the given number of spaces.
#
################################################################################

__print_pad () {
seq 1 "${1}" | while read -r __line; do
    echo -n ' '
done
}

################################################################################
#
# __format_text <LEADER> <TEXT> <TRAILER>
#
# Pads text to a set length, so multiline warnings, info and errors can be made.
#
################################################################################

__format_text () {
echo -ne "${1}"
local __desired_size='7'
local __leader_size="$(echo -ne "${1}" | __strip_ansi | wc -m)"
local __clipped_size=$((__desired_size-__leader_size-3))
local __front_pad="$(__print_pad "${__clipped_size}") - "
echo -ne "${__front_pad}"
local __pad=''

if [ "$(wc -l <<< "${2}")" -gt '1' ]; then
    head -n -1 <<< "${2}" | while read -r __line; do
        if [ -z "${__pad}" ]; then
            echo -e "${__pad}${__line}"
            local __pad="$(__print_pad "${__desired_size}")"
        else
            echo -e "${__pad}${__line}"
        fi
    done
    local __pad="$(__print_pad "${__desired_size}")"
    echo -e "${__pad}$(tail -n 1 <<< "${2}")${3}"
else
    echo -e "${2}${3}"
fi

}

################################################################################
#
# __bypass_announce <MESSAGE>
#
# Bypass Announce
# Echos a statement no matter what.
#
################################################################################

__bypass_announce () {
__format_text "\e[32mINFO\e[39m" "${1}" ""
}

################################################################################
#
# __force_announce <MESSAGE>
#
# Force Announce
# Echos a statement, when __quiet is equal to 0.
#
################################################################################

__force_announce () {
if [ "${__quiet}" = '0' ]; then
    __bypass_announce "${1}"
fi
}

################################################################################
#
# __announce <MESSAGE>
#
# Announce
# Echos a statement, only if __verbose is equal to 1.
#
################################################################################

__announce () {
if [ "${__time}" = '0' ] && [ "${__verbose}" = '1' ] && ! [ "${__name_only}" = '1' ] && ! [ "${__list_changed}" = '1' ]; then
    __force_announce "${1}"
fi
}

################################################################################
#
# __force_warn <MESSAGE>
#
# Warn
# Echos a statement when something has gone wrong.
#
################################################################################

__force_warn () {
if ! [ "${__name_only}" = '1' ] && ! [ "${__list_changed}" = '1' ]; then
    __format_text "\e[93mWARN\e[39m" "${1}" ", continuing anyway." 1>&2
fi
}

################################################################################
#
# __warn <MESSAGE>
#
# Warn
# Echos a statement when something has gone wrong, to be used when it is
# tolerable.
#
################################################################################

__warn () {
if [ "${__very_verbose}" = '1' ] || [ "${__should_warn}" = '1' ]; then
if ! [ "${__name_only}" = '1' ] && ! [ "${__list_changed}" = '1' ]; then
    __force_warn "${@}"
fi
fi
}

################################################################################
#
# __custom_error <MESSAGE>
#
# Custom Error
# Echos an error statement without quiting.
#
################################################################################

__custom_error () {
__format_text "\e[31mERRO\e[39m" "${1}" "${2}" 1>&2
}

################################################################################
#
# __error <MESSAGE>
#
# Error
# Echos a statement when something has gone wrong, then exits.
#
################################################################################

__error () {
__custom_error "${1}" ", exiting."
exit 1
}

################################################################################
#
# __force_time <MESSAGE> <start/end>
#
# Force Time
# Times between two occurrences of the function, as set by start or end, only if
# time is on.
#
################################################################################

__force_time () {
local __message="$(__hash <<< "${1}" | sed 's/ .*//')"

if ! [ "${#}" = '2' ]; then
    __force_warn "Invalid number of options for time function"
else

if [ "${2}" = 'start' ]; then
    export "__function_start_time${__message}"="$(date +%s.%N)"
    return 0
elif [ "${2}" = 'end' ]; then
    export "__function_end_time${__message}"="$(date +%s.%N)"
else
    if ! [ "${__name_only}" = '1' ] && [ "${__time}" = '1' ] && ! [ "${__list_changed}" = '1' ]; then
        __force_warn "Invalid option \"${2}\" to time function"
    fi
    return 1
fi

if ! [ "${__name_only}" = '1' ] && [ "${__time}" = '1' ] && ! [ "${__list_changed}" = '1' ]; then
    local __f_start="__function_start_time${__message}"
    local __f_end="__function_end_time${__message}"

    if [ -z "${!__f_start}" ]; then
        __force_warn "Timer for \"${1}\" was never started"
        return 1
    elif [ -z "${!__f_end}" ]; then
        __force_warn "Timer for \"${1}\" failed to end"
        return 1
    fi

    __format_text "\e[32mTIME\e[39m" "$(bc <<< "${!__f_end}-${!__f_start}" | sed 's/^\./0./') seconds - ${1}" ""
fi

fi
}

################################################################################
#
# __time <MESSAGE> <start/end>
#
# Time
# Times between two occurrences of the function, as set by start or end, only if
# verbose is on.
#
################################################################################

__time () {
if [ "${__verbose}" = '1' ]; then
    __force_time "${1}" "${2}"
fi
}
