_smelt () {
    local cur prev sizes rundir helper sizes graph_formats items graphers
    _init_completion || return

    rundir="$(dirname "$(readlink -f "$(which "${1}")")")"
    helper="${rundir}/smelt_helper.sh"
    sizes=$(seq 5 10 | sed 's/^/2^/' | bc)
    graph_formats='bmp canon dot gv xdot xdot1.2 xdot1.4 cgimage cmap eps exr fig gd gd2 gif gtk ico imap cmapx imap_np cmapx_np ismap jp2 jpg jpeg jpe json json0 dot_json xdot_json pct pict pdf pic plain plain-ext png pov ps ps2 psd sgi svg svgz tga tif tiff tk vml vmlz vrml wbmp webp xlib x11'
    graphers='dot neato twopi circo fdp sfdp patchwork osage'
    if [ -e './src/xml/list' ]; then
        items="$(cat './src/xml/list')"
    else
        items='error'
    fi


    case ${prev} in
        '-?' | '-h' | '--help')
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
            COMPREPLY=($(compgen -W "${items}" -- "${cur}"))
            return 0
            ;;

        "--grapher")
            COMPREPLY=($(compgen -W "${graphers}" -- "${cur}"))
            return 0
            ;;

        "--graph-seed")
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

complete -F _smelt smelt

# ex: ts=4 sw=4 et filetype=sh
