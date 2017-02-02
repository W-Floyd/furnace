#!/bin/bash

################################################################
# __usage
#
# Prints the usage of the program
__usage () {
echo "${0} <OPTIONS> <SIZE>

Makes the texture pack at the specified size(s) (or using
default list of sizes). Order of options and size(s) are not
important.

Options:
  -h  --help  -?        This help message
  -v  --verbose         Be verbose
  -vv --very-verbose    Be very verbose
  -i  --install         Install or update .minecraft folder copy
  -m  --mobile          Make mobile resource pack as well
  -t  --time            Time functions (for debugging)
  -d  --debug           Use debugging mode\
"
}
################################################################

################################################################
# __error <MESSAGE GOES HERE>
#
# Spits out an error message and exist appropriately
__error () {
    echo -e "\e[31mError\e[39m   - ${@}, exiting"
    exit 1
}
################################################################

################################################################
# __warn <MESSAGE GOES HERE>
#
# Spits out a warning message
__warn () {
    echo -e "\e[93mWarning\e[39m - ${@}, continuing anyway"
}
################################################################

################################################################
# Default variables
#__dir_bin='/usr/share/mc-resource-packer'
__dir_bin='/home/william/Documents/git/Original/mc-resource-packer'
__dir_top="$(pwd)"
__file_config_script='config.sh'
__file_default_functions="${__dir_bin}/functions.sh"
__dir_source='src'
__dir_scripts='scripts'
__file_catalogue='catalogue.xml'
################################################################

################################################################
# Checking for default functions
if [ -e "${__file_default_functions}" ]; then
    source "${__file_default_functions}" &> /dev/null || __error "Defaults functions could not be set, this should never happen"
else
    __warn "Defaults functions '${__file_default_functions}' are missing, this should never happen"
fi
################################################################

################################################################
# Set whatever things are in the config script
if [ -e "${__file_config_script}" ]; then
    source "${__file_config_script}" || __error "Config script ran with errors, this should never happen"
else
    __warn "Config script missing, using default values"
fi
################################################################

################################################################
# Check for required directories
if ! [ -d "${__dir_source}" ]; then
    __error "Missing source directory"
elif ! [ -d "${__dir_scripts}" ]; then
    __error "Missing scripts directory"
fi
################################################################

################################################################
# Check for required files
if ! [ -e "${__file_catalogue}" ]; then
    __error "Missing catalogue file"
fi
################################################################

__list_fields='CONFIG
SIZE
OPTIONS
KEEP
DEPENDS
CLEANUP
COMMON'

declare -A __array_catalogue

# TODO - WHY IS THIS NOT WORKING?

__get_range "${__file_catalogue}" ITEM | while read __var_range; do
    __var_tmp_range="$(__read_range "${__file_catalogue}" "${__var_range}")"
    __var_tmp_name="$(__get_value "NAME" <<< "${__var_tmp_range}")"
    for __var_field in ${__list_fields}; do
        declare -A __array_catalogue["${__var_tmp_name}","${__var_field}"]="$(__get_value "${__var_field}" <<< "${__var_tmp_range}")"
    done
done

echo "${__array_catalogue[@]}"

exit
