_furnace () {
    local cur prev sizes rundir helper sizes graph_formats matches items graphers ignore_list prefix candidates tmpvar

    _init_completion || return

    rundir="$(dirname "$(readlink -f "$(which "${1}")")")"
    helper="${rundir}/furnace_helper.sh"
    sizes=$(seq 5 10 | sed 's/^/2^/' | bc)
    ignore_list='-h'
    graph_formats='bmp canon dot gv xdot xdot1.2 xdot1.4 cgimage cmap eps exr fig gd gd2 gif gtk ico imap cmapx imap_np cmapx_np ismap jp2 jpg jpeg jpe json json0 dot_json xdot_json pct pict pdf pic plain plain-ext png pov ps ps2 psd sgi svg svgz tga tif tiff tk vml vmlz vrml wbmp webp xlib x11'

    _get_comp_words_by_ref -n = cur prev

    case "${prev}" in
        '-?' | '-h' | '--help' | "--completed")
            return 0
            ;;

        "--function="*)
            prefix="$(cat <<< "${prev}" | sed 's/^--function=//')"
            COMPREPLY=($(compgen -W "$(${helper} --function "${prefix}")" -- "${cur}"))
            return 0
            ;;

    esac

    case "${cur}" in
        "--graph="*)
            if grep -q ',' <<< "${cur#*=}"; then
                local __stripped_cur="$(sed 's#\(.*\),\([^,]*\)$#\2#' <<< "${cur#*=}")"
                local __prev_matches="$(sed -e 's#\(.*\),\([^,]*\)$#\1#' -e 's/$/,/' <<< "${cur#*=}")"
            else
                local __stripped_cur="${cur#*=}"
                local __prev_matches=''
            fi
            if [ -e './src/xml/list' ]; then
                matches="$(grep "^${__stripped_cur}" < './src/xml/list' | sed "s#^\(${__stripped_cur}[^/]*/\)\(.*\)#\1#")"
                items="$(sort <<< "${matches}" | uniq | sed -e 's/$/ /' -e "s#^#${__prev_matches}#")"
            else
                items=''
            fi

            COMPREPLY=($(compgen -W "${items}" -- "${cur#*=}"))
            if [ "$(wc -l <<< "${matches}")" -gt 1 ]; then
                compopt -o nospace
            fi
            return 0
            ;;

        "--graph-format="*)
            COMPREPLY=($(compgen -W "${graph_formats}" -- "${cur#*=}"))
            return 0
            ;;

        "--function="*)
            COMPREPLY=($(compgen -W "$("${helper}" --list-prefixes | tr '\n' ' ')" -- "${cur#*=}"))
            return 0
            ;;

        "--png-compression="*)
            COMPREPLY=($(compgen -W "$(seq 0 10 100)" -- "${cur#*=}"))
            return 0
            ;;

        "--name="*)
            candidates="$(basename "$(pwd)" | rev | sed -e 's/.*-//' -e 's/.*_//' -e 's/.*\.//' | rev; basename "$(pwd)")"
            COMPREPLY=($(compgen -W "${candidates}" -- "${cur#*=}"))
            return 0
            ;;

        "--optional="* | "--max-optional="* | "--max-optimize="*)
            COMPREPLY=($(compgen -W "${sizes}" -- "${cur#*=}"))
            return 0
            ;;

        "--"*"=")
            return 0
            ;;

        -*)
            tmpvar="$(_parse_help "${1}" | grep -vxF -- "${ignore_list}")"
            COMPREPLY=( $( compgen -W "${tmpvar}" -- "${cur}" ) )
            if [ "$(wc -l <<< "${COMPREPLY}")" = '1' ]; then
                if grep -qE '=$' <<< "${COMPREPLY}"; then
                    compopt -o nospace
                fi
            fi
            return 0
            ;;

        [0-9]*)
            COMPREPLY=($(compgen -W "${sizes}" -- "${cur}"))
            return 0
            ;;
    esac

} &&

complete -F _furnace furnace

# ex: ts=4 sw=4 et filetype=sh
