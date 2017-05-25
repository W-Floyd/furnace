################################################################################
# Routine Functions
################################################################################

################################################################################
#
# These will be used to choose alternative methods of doing things (optimize,
# vector render, etc.)
#
################################################################################

################################################################################
#
# __list_prefixes
#
# List Prefixes
# Lists all known prefixes for routines.
#
################################################################################

__list_prefixes () {

compgen -A function | grep "^__routine__" | sort | sed "s/^__routine__//" | sed 's/__.*//' | sort | uniq

}

################################################################################
#
# __check_command <COMMAND>
#
# Check command
# Wraps a quiet which for use in tests. Returns 0 on success, 1 on failure.
#
################################################################################

__check_command () {

if which "${1}" &> /dev/null; then
    return 0
else
    return 1
fi

}

################################################################################
#
# __list_functions <PREFIX>
#
# List Functions
# Lists functions that use the given prefix (that is, "__<PREFIX>_<COMMAND>")
#
# For example:
#
# $ __list_functions vector_render
#
# might return
#
# > inkscape
# > rsvg-convert
#
# having matched with '__vector_render_inkscape' and
# '__vector_render_rsvg-convert'
#
# Note the output format - it is cleaned to the command name itself.
#
################################################################################

__list_functions () {

compgen -A function | grep "^__routine__${1}__" | sort | sed "s/^__routine__${1}__//"

}


################################################################################
#
# __test_function <PREFIX> <COMMAND>
#
# Test Function
# Tests a function, both for existence of a function, and for the existence of
# the corresponding internal command. Returns 0 on success, 1 all other cases.
#
################################################################################

__test_function () {

if __check_command "${2}" && [ "$(type -t "__routine__${1}__${2}")" = 'function' ]; then
    return 0
else
    return 1
fi

}

################################################################################
#
# __test_routine <PREFIX>
#
# Test Routine
# Tests to see if a routine is available for the given PREFIX, assumes that
# __choose_function has already been run.
#
################################################################################

__test_routine () {

local __function_name="__function_${1}"

if [ -z "${!__function_name}" ]; then

    return 1

else

    return 0

fi

}

################################################################################
#
# __choose_function <OPTIONAL_FLAGS> <PREFIX>
#
# Choose Function
# Chooses a function that exists, given the prefix of the function.
# NOTE - It is important to declare the PREFIX *LAST*
#
# Optional flags include:
#   -e                  Error out if missing
#   -d <DESCRIPTION>    Description to be used when reporting that no function
#                       was found.
#   -p <LIST>           Line and/or space separated list of functions in order
#                       of preference (hence, -p)
#   -f                  Force choose. That is, ignore the currently chosen
#                       routine and choose a new one. Otherwise, uses existing
#                       choice by default, if valid, else, chooses a new one.
#
# Sets a variable __function_${__function_prefix}"="${__function}"
#
# So, for example, with vector rendering, inkscape and rsvg-convert are supposed
# to be possible candidates, with rsvg-convert being prefered (speed is far
# better). So an example might be like follows:
#
# $ __choose_function vector_render -e -d 'vector rendering' -p 'rsvg-convert'
#
# That means, in words: search for functions that begin with __vector_render_
# (prefix), putting rsvg-convert first in order of preference
# (-p 'rsvg-convert'). Should a successful routine be found (checking for both
# rsvg-convert as an excecutable, AND __vector_render_rsvg-convert as a
# function), __function_vector_render will be set to 'rsvg-convert'. If
# no routine is found that works, then amessage stating "No valid routine for
# vector rendering found" is printed (-d 'vector rendering'), before erroring
# out (-e).
#
################################################################################

__choose_function () {

__debug_toggle off

local __should_error='0'
local __should_force='0'
local __preference_list=''
local __description=''
local __function_prefix=''
local __function_name=''

if ! [ "${#}" = 0 ]; then

    while ! [ "${#}" = '0' ]; do

        case "${__last_option}" in

            "-p")

                __preference_list+="
${1}"

                ;;

            "-d")

                __description="${1}"

                ;;

            *)

                case "${1}" in

                    "-e")
                        __should_error='1'
                        ;;

                    "-f")
                        __should_force='1'
                        ;;

                     "-p")
                        ;;

                     "-d")
                        ;;

	                *)
	                    __function_prefix="${1}"
	                    __function_name="__function_${__function_prefix}"
# Neat trick I found here:
# http://stackoverflow.com/questions/14049057/bash-expand-variable-in-a-variable
# Means no more eval sodomy :3
	                    if ! [ -z "${!__function_name}" ] && [ "${__should_force}" = '0' ] && __test_function "${__function_prefix}" "${!__function_name}"; then
	                        __debug_toggle off on
                            return 0
                        fi

                        ;;

                esac
                ;;

        esac

        local __last_option="${1}"

        shift

    done

else

    __debug_toggle on

    __error "No options passed"

fi

export "__function_${__function_prefix}"="$(
{
echo "${__preference_list}"
__list_functions "${__function_prefix}"
} | tr ' ' '\n' | __funiq | while read -r __function; do

    if __test_function "${__function_prefix}" "${__function}"; then
        echo "${__function}"
        break
    fi

done
)"

if ! __test_routine "${__function_prefix}"; then

    if [ -z "${__description}" ]; then
        __description="${__function_prefix}"
    fi

    local __message="No valid routine for ${__description} found"

    if [ "${__should_error}" = '1' ]; then
        __debug_toggle on
        __error "${__message}"
    else
        __force_warn "${__message}"
    fi

fi

__debug_toggle on

}

################################################################################
#
# __run_routine <PREFIX> <ALL_OTHER_OPTIONS>
#
# Run Routine
# Verifies and runs the routine for the given PREFIX.
# For example, rather than typing it out yourself, you can do:
#
# $ __run_routine vector_render file.svg
#
# Finds that __vector_render_rsvg-convert is the blessed routine, and passes
# 'file.svg' to it.
#
# And so the rabbit hole begins...
#
################################################################################

__run_routine () {

__debug_toggle off

if read -r -t 0; then
    local __pipe="$(cat)"
else
    local __pipe=''
fi

local __function_prefix="${1}"
shift

__debug_toggle on

__choose_function "${__function_prefix}"

__debug_toggle off

local __function_name="__function_${__function_prefix}"

local __routine_name="__routine__${__function_prefix}__${!__function_name}"

__debug_toggle on

"${__routine_name}" "${@}" <<< "${__pipe}"

}

################################################################################
#
# __set_routine <PREFIX> <ROUTINE>
#
# Set Routine
# A shortcut to set routine for a given prefix
#
################################################################################

__set_routine () {
export "__function_${1}=${2}"
}
