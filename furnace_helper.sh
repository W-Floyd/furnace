#!/bin/bash

export __run_dir="$(dirname "$(readlink -f "${0}")")"
export __furnace_setup_bin="${__run_dir}/furnace_setup.sh"

# get set up
source "${__furnace_setup_bin}" &> /dev/null || { echo "Failed to load setup \"${__furnace_setup_bin}\""; exit 1; }

# If there are any options,
if ! [ "${#}" = 0 ]; then

# then let's look at them in sequence.
while ! [ "${#}" = '0' ]; do

    case "${1}" in

        "--list-prefixes")
            __list_prefixes
            exit 0
            ;;

        "--function")
            __list_functions "${2}"
            exit 0
            ;;

        *)
            __custom_error "Unknown option \"${1}\""
            __usage
            exit 1
            ;;

    esac

    shift

done

fi


exit
