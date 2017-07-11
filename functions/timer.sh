################################################################################
# Timing Functions
################################################################################

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
if [ -z "${__tmp_timer_var}" ] || [ "${__tmp_timer_var}" = 'end' ]; then
    export __tmp_timer_var='start'
    if [ -z "${__tmp_timer_iteration}" ]; then
        export __tmp_timer_iteration='1'
    else
        __tmp_timer_iteration=$((__tmp_timer_iteration+1))
    fi
elif [ "${__tmp_timer_var}" = 'start' ]; then
    export __tmp_timer_var='end'
fi

local message="Temporary Timer ${__tmp_timer_iteration}"

__force_timer "${__tmp_timer_var}" "${message}"
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

__format_text "$(__colorize -f 'TIME' green bold)" "$(sed 's/^\./0\./' <<< "${__timer[${1}]}") seconds - ${__timer_description[${1}]}" ""
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
        sort -grk 3
    else
        cat
    fi
    )
    )"
    if ! [ -z "${__end}" ]; then
        if [ "${__final}" = '1' ] && [ "${__verbose}" = '1' ]; then
            __format_text "$(__colorize -f 'TIME' green bold)" "General Timing" ""
        fi
        echo -e "${__end}"
        if [ "${__final}" = '0' ]; then
            echo
        fi
    fi
fi
}
