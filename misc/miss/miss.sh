#!/bin/sh

ish_ctx_cli_miss_count() { _meta $0
    local prefix="" num=1 && while [ "$#" -gt 0 ]; do
        case "$1" in
            prepare) prefix="$2";;
            process) prefix="$(_color green $2)";;
            finish) prefix="$(_color red $2)";;
            cancel) prefix="$(_color yellow $2)";;
        esac
        echo "$((num++)).$prefix" && shift 2
    done
}

ish_ctx_cli_miss_create() {
    tmux has-session -t miss &>/dev/null && return

    tmux new-session -d -s miss -n shy
    tmux split-window -p 30 -t miss:shy.1
    tmux split-window -h -t miss:shy.2

    tmux send-keys -t miss:shy.3 "tail -f bin/boot.log" Enter
    tmux send-keys -t miss:shy.2 "bin/ice.sh start serve shy" Enter
    tmux send-keys -t miss:shy.1 "vim" Enter
}
ish_ctx_cli_miss_attach() {
    script create
    tmux attach-session -t miss
}

