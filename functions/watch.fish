function watch --description 'Repeatedly run a command every 2 seconds'
    while true
        clear
        set_color yellow
        echo "Custom watch loop (fish). Press Ctrl+C to stop."
        echo "Command: $argv"
        set_color normal
        echo "------------------------------------------"
        eval $argv
        sleep 2
    end
end
