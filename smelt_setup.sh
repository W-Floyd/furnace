export __smelt_functions_bin="${__run_dir}/smelt_functions.sh"
export __smelt_image_functions_bin="${__run_dir}/smelt_image_functions.sh"
export __smelt_render_bin="${__run_dir}/smelt_render.sh"
export __smelt_completed_bin="${__run_dir}/smelt_completed.sh"
export __smelt_graph_bin="${__run_dir}/smelt_graph.sh"
export __standard_conf_dir="${__run_dir}/conf"
export __catalogue='catalogue.xml'
export PS4='Line ${LINENO}: '

# get functions from file
source "${__smelt_functions_bin}" &> /dev/null || { echo "Failed to load functions \"${__smelt_functions_bin}\""; exit 1; }

# get functions from file
source "${__smelt_image_functions_bin}" &> /dev/null || __error "Failed to load image functions \"${__smelt_image_functions_bin}\""

################################################################

if ! [ -e 'config.sh' ]; then
    __force_warn "No config file was found, using default values"
else
    if [ "$(head -n 1 'config.sh')" = '#smeltconfig#' ]; then
        source 'config.sh' || __error "Config file has an error"
    else
        __error "Config does not have correct header \"#smeltconfig#\""
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
