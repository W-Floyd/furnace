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
# __force_timer start|end|reset> <MESSAGE>
#
# Forced Timer
# Times between two occurrences of the function, as set by start or end.
#
# Retrieve this time with "__get_timer <MESSAGE>"
#
################################################################################

__force_timer () {
declare -gA __timer __timer_description __timer_start
if __check_function __restore_array; then
    __restore_array __timer __timer_description __timer_start
    unset -f __restore_array
fi
local __curtime="$(date +%s.%N)"
local __description="${2}"
local __hash="$(__timer_hash <<< "${__description}")"
if [ -z "${__time[${__hash}]}" ]; then
    __timer[${__hash}]='0'
fi
if [ -z "${__timer_description[${__hash}]}" ]; then
    __timer_description[${__hash}]="${2}"
fi
if [ "${1}" = 'start' ]; then
    __timer_start[${__hash}]="${__curtime}"
elif [ "${1}" = 'end' ]; then
    if [ -z "${__timer_start[${__hash}]}" ]; then
        __force_warn "Timer for '${__description}' was never started"
    else
        local __math="0${__timer[${__hash}]}+(0${__curtime}-0${__timer_start[${__hash}]})"
        __timer[${__hash}]="$(bc -l <<< "${__math}")"
    fi
elif [ "${1}" = 'reset' ]; then
    __timer[${__hash}]='0'
else
    __error 'Timer derp'
fi
__save_array __timer __timer_description __timer_start
}

################################################################################
#
# __timer start|end|reset> <MESSAGE>
#
# Timer
# Same as Forced Timer, but obeys verbosity
#
################################################################################

__timer () {
if [ "${__verbose}" = '1' ]; then
    __force_timer "${@}"
fi
}

################################################################################
#
# __timer_hash <MESSAGE>
#
# Timer Hash
# Standard hashing procedure for timing. Namely, strips spaces and adds a
# leading X in order to work with arrays.
#
################################################################################

__timer_hash () {
cat | __hash | sed -e 's/ .*//' -e 's/^/X/'
}

################################################################################
#
# __tmp_timer
#
# Temporary Timer
# Temporary timer that automatically toggles. Useful for optimization.
#
################################################################################

__tmp_timer () {
if [ -z "${__tmp_time_var}" ] || [ "${__tmp_time_var}" = 'end' ]; then
    export __tmp_time_var='start'
elif [ "${__tmp_time_var}" = 'start' ]; then
    export __tmp_time_var='end'
fi
__force_timer "${__tmp_time_var}" "temporary timer"
if [ -z "${__tmp_time_var}" ] || [ "${__tmp_time_var}" = 'end' ]; then
    __get_timer "temporary timer"
    __timer reset "temporary timer"
fi
}

################################################################################
#
# __get_timer <MESSAGE>
#
# Get Timer
# Gets the cumulative time of the given MESSAGE.
# If no time is found, returns 1 and is silent.
#
################################################################################

__get_timer () {
if [ -z "${__timer[${1}]}" ]; then
    return 1
fi

__format_text "\e[32mTIME\e[39m" "$(sed 's/^\./0\./' <<< "${__timer[${1}]}") seconds - ${__timer_description[${1}]}" ""
}

################################################################################
#
# __save_timer
#
# Save Timer
# Saves timing arrays.
#
################################################################################

__save_timer () {
__save_array __timer __timer_description __timer_start
}

################################################################################
#
# __restore_timer
#
# Restore Timer
# Restores timing arrays.
#
################################################################################

__restore_timer () {
if __check_function __restore_array; then
    __restore_array __timer __timer_description __timer_start
else
    __force_warn "Timer arrays were not available to restore"
fi
}

################################################################################
#
# __print_timer [-s] [-f]
#
# Print Timer
# Prints timing information, optionally sorted
#
################################################################################

__print_timer () {
local __sort='0'
local __final='0'
until [ "${#}" = '0' ]; do
    case "${1}" in
        '-s')
            local __sort='1'
            ;;
        '-f')
            local __final='1'
            ;;
    esac
    shift
done
if ! [ "${__name_only}" = '1' ] && [ "${__time}" = '1' ] && ! [ "${__list_changed}" = '1' ]; then

    local __end="$(
    for __item in "${!__timer_description[@]}"; do
        __get_timer "${__item}" || continue
    done | (
    if [ "${__sort}" = '1' ]; then
        sort -rg
    else
        cat
    fi
    )
    )"
    if ! [ -z "${__end}" ]; then
        if [ "${__final}" = '1' ] && [ "${__verbose}" = '1' ]; then
            __format_text "\e[32mTIME\e[39m" "General Timing" ""
        fi
        echo -e "${__end}"
        if [ "${__final}" = '0' ]; then
            echo
        fi
    fi
fi
}
