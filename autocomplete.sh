_smelt () {
    local cur prev sizes rundir helper
    _init_completion || return

    rundir="$(dirname "$(readlink -f "$(which ${1})")")"
    helper="${rundir}/smelt_helper.sh"
    sizes=$(for num in $(seq 5 12); do echo "2^${num}" | bc; done)

    case ${prev} in
        -'?'|-h|--help)
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

    esac

    case "${cur}" in
        -*)
            COMPREPLY=( $( compgen -W '$( _parse_help "${1}" )' -- "${cur}" ) )
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
