function watch --description 'Repeatedly run a command'
    argparse 'n/interval=' -- $argv
    or return

    if not set -q argv[1]
        echo "watch: missing command" >&2
        return 1
    end

    set -l interval 2
    if set -q _flag_interval
        set interval $_flag_interval
    end

    while true
        clear
        set_color yellow
        echo "Custom watch loop (fish). Press Ctrl+C to stop."
        echo "Command: $argv"
        echo "Interval: $interval seconds"
        set_color normal
        echo "------------------------------------------"
        eval $argv
        sleep $interval
    end
end

