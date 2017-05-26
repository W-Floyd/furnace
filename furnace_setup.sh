__check_var () {
if [ -z "${!1}" ]; then
    echo "${1} not declared, exiting."
    exit 1
fi
}

__source_functions () {
cp "${1}" '/tmp/script.sh'
echo 'for __function in $(compgen -A function); do
    export -f ${__function}
done' >> '/tmp/script.sh'
source '/tmp/script.sh' || { echo "Failed to load functions from \"${1}\"" 1>&2; exit 1; }
rm '/tmp/script.sh'
}

__check_var __run_dir

# Source all function files
if [ -d "${__run_dir}/functions" ]; then
    while read -r __file; do
        __source_functions "${__file}"
    done <<< "$(find "${__run_dir}/functions" -type f; find "${__run_dir}/functions" -type l)"
fi

export __furnace_render_bin="${__run_dir}/furnace_render.sh"
export __furnace_completed_bin="${__run_dir}/furnace_completed.sh"
export __furnace_graph_bin="${__run_dir}/furnace_graph.sh"
export __catalogue='catalogue.xml'
export PS4='Line ${LINENO}: '

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
        __source_functions "${__custom_function_bin}" &> /dev/null || "Failed to load custom functions \"${__custom_function_bin}\""
    else
        __error "Custom functions file \"${__custom_function_bin}\" is missing"
    fi
fi

while read -r __dep; do
    if ! __check_command "${__dep}"; then
        __error "Please install \"${__dep}\""
    fi
done <<< "pcregrep"

if ! [ -z "${__pack_depends}" ]; then
    for __dep in ${__pack_depends}; do
        if ! __check_command "${__dep}"; then
            __error "Please install \"${__dep}\" to render this pack"
        fi
    done
fi

################################################################

__choose_function -e -d 'file hashing' -p 'md5sum' 'hash'
