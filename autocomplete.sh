_furnace () {
    local cur prev sizes rundir helper sizes graph_formats matches items \
    graphers ignore ignore_list prefix candidates tmpvar

    _init_completion || return

    rundir="$(dirname "$(readlink -f "$(which "${1}")")")"
    helper="${rundir}/furnace_helper.sh"
    sizes=$(seq 5 10 | sed 's/^/2^/' | bc)
    ignore_list='-h'
    graph_formats='bmp canon dot gv xdot xdot1.2 xdot1.4 cgimage cmap eps exr \
    fig gd gd2 gif gtk ico imap cmapx imap_np cmapx_np ismap jp2 jpg jpeg jpe \
    json json0 dot_json xdot_json pct pict pdf pic plain plain-ext png pov ps \
    ps2 psd sgi svg svgz tga tif tiff tk vml vmlz vrml wbmp webp xlib x11'
    graphers='dot neato twopi circo fdp sfdp patchwork osage'

    _get_comp_words_by_ref -n = cur prev

    case "${prev}" in
        '-?' | '-h' | '--help' | "--graph-seed" | "--completed")
            return 0
            ;;

        '--max-optimize')
            COMPREPLY=($(compgen -W "${sizes}" -- "${cur}"))
            return 0
            ;;

        "--graph")

                if [ -e './src/xml/list' ]; then
                    matches="$(grep "^${cur}" < './src/xml/list' | sed "s#^\(${cur}[^/]*/\)\(.*\)#\1#")"
                    items="$(sort <<< "${matches}" | uniq | sed 's/$/ /')"
                else
                    items=''
                fi

            if ! [[ "${cur}" == "-"* ]]; then
                COMPREPLY=($(compgen -W "${items}" -- "${cur}"))
                if [ "$(echo "${matches}" | wc -l )" -gt 1 ]; then
                    compopt -o nospace
                fi
                return 0
            fi
            ;;

        "--function="*)
            prefix="$(cat <<< "${prev}" | sed 's/^--function=//')"
            COMPREPLY=($(compgen -W "$(${helper} --function "${prefix}")" -- "${cur}"))
            return 0
            ;;

    esac

    case "${cur}" in
        "--grapher="*)
            COMPREPLY=($(compgen -W "${graphers}" -- "${cur#*=}"))
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
