_smelt () {
    local cur prev sizes rundir helper sizes graph_formats items
    _init_completion || return

    rundir="$(dirname "$(readlink -f "$(which "${1}")")")"
    helper="${rundir}/smelt_helper.sh"
    sizes=$(seq 5 10 | sed 's/^/2^/' | bc)
    graph_formats='dot xdot ps pdf svg svgz fig png gif gtk jpg jpeg json imap xmapx'
    if [ -e './src/xml/list' ]; then
        items="$(cat './src/xml/list')"
    else
        items='error'
    fi


    case ${prev} in
        -'?'|-h|--help)
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
