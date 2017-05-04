_furnace () {
    local cur prev sizes rundir helper sizes graph_formats matches items graphers
    _init_completion || return

    rundir="$(dirname "$(readlink -f "$(which "${1}")")")"
    helper="${rundir}/furnace_helper.sh"
    sizes=$(seq 5 10 | sed 's/^/2^/' | bc)
    graph_formats='bmp canon dot gv xdot xdot1.2 xdot1.4 cgimage cmap eps exr fig gd gd2 gif gtk ico imap cmapx imap_np cmapx_np ismap jp2 jpg jpeg jpe json json0 dot_json xdot_json pct pict pdf pic plain plain-ext png pov ps ps2 psd sgi svg svgz tga tif tiff tk vml vmlz vrml wbmp webp xlib x11'
    graphers='dot neato twopi circo fdp sfdp patchwork osage'
    if [ -e './src/xml/list' ]; then
        matches="$(grep "^${cur}" < './src/xml/list' | sed "s#^\(${cur}[^/]*/\)\(.*\)#\1#")"
        items="$(sort <<< "${matches}" | uniq | sed 's/$/ /')"
    else
        items=''
    fi


    case "${prev}" in
        '-?' | '-h' | '--help' | "--graph-seed" | "--completed")
            return 0
            ;;

        '--max-optimize')
            COMPREPLY=($(compgen -W "${sizes}" -- "${cur}"))
            return 0
            ;;

        '--optimizer')
            COMPREPLY=($(compgen -W "$(${helper} --optimizer)" -- "${cur}"))
            return 0
            ;;

        '--name')
            COMPREPLY=($(compgen -W "$(basename "$(pwd)" | rev | sed -e 's/.*-//' -e 's/.*_//' -e 's/.*\.//' | rev)" -- "${cur}"))
            return 0
            ;;

        "--graph-format")
            COMPREPLY=($(compgen -W "${graph_formats}" -- "${cur}"))
            return 0
            ;;

        "--graph")
            if ! [[ "${cur}" == "-"* ]]; then
                COMPREPLY=($(compgen -W "${items}" -- "${cur}"))
                if [ "$(echo "${matches}" | wc -l )" -gt 1 ]; then
                    compopt -o nospace
                fi
                return 0
            fi
            ;;

        "--grapher")
            COMPREPLY=($(compgen -W "${graphers}" -- "${cur}"))
            return 0
            ;;

    esac

    case "${cur}" in
        -*)
            COMPREPLY=( $( compgen -W "$( _parse_help "${1}" )" -- "${cur}" ) )
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
