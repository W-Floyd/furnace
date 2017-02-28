_smelt () {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts="--help --verbose --install --mobile --slow --time --debug --lengthy --force --quiet --warn --compress --force-xml --completed"


    case "${cur}" in
        -*)
            COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
            return 0
            ;;
        [0-9]*)
            local sizes
            sizes=$(for num in $(seq 5 12); do echo "2^${num}" | bc; done)
            COMPREPLY=($(compgen -W "${sizes}" -- "${cur}"))
            return 0
            ;;
        *)
        ;;
    esac

} &&

complete -F _smelt smelt
