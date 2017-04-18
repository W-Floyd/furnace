export __furnace_functions_bin="${__run_dir}/furnace_functions.sh"
export __furnace_image_functions_bin="${__run_dir}/furnace_image_functions.sh"
export __furnace_render_bin="${__run_dir}/furnace_render.sh"
export __furnace_completed_bin="${__run_dir}/furnace_completed.sh"
export __furnace_graph_bin="${__run_dir}/furnace_graph.sh"
export __standard_conf_dir="${__run_dir}/conf"
export __catalogue='catalogue.xml'
export PS4='Line ${LINENO}: '

# get functions from file
source "${__furnace_functions_bin}" &> /dev/null || { echo "Failed to load functions \"${__furnace_functions_bin}\""; exit 1; }

# get functions from file
source "${__furnace_image_functions_bin}" &> /dev/null || __error "Failed to load image functions \"${__furnace_image_functions_bin}\""

################################################################

if ! [ -e 'config.sh' ]; then
    __force_warn "No config file was found, using default values"
else
    if [ "$(head -n 1 'config.sh')" = '#furnaceconfig#' ]; then
        cp 'config.sh' '/tmp/config.sh'
        __tmpvar="$(
        echo \
'echo "something to use a pipe" | rev > /dev/null
compgen -A variable > /tmp/tmpvars'

        cat '/tmp/config.sh'
        
        echo \
'compgen -A variable > /tmp/tmpvars2
for __variable in $(grep -Fxvf /tmp/tmpvars /tmp/tmpvars2); do
    export "${__variable}"
done'
)" 
        echo "${__tmpvar}" > '/tmp/config.sh'
        source '/tmp/config.sh' || __error "Config file has an error"
        rm '/tmp/config.sh'
    else
        __error "Config does not have correct header \"#furnaceconfig#\""
    fi
fi

################################################################

if ! [ -z "${__custom_function_bin}" ]; then
    if [ -e "${__custom_function_bin}" ]; then
        source "${__custom_function_bin}" &> /dev/null || "Failed to load custom functions \"${__custom_function_bin}\""
    else
        __error "Custom functions file \"${__custom_function_bin}\" is missing"
    fi
fi

while read -r __dep; do
	if ! which "${__dep}" &> /dev/null; then
		__error "Please install \"${__dep}\""
	fi
done <<< "pcregrep"
