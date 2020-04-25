#!/bin/sh

${ISH_CTX_SCRIPT}_count() { _meta $0
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

${ISH_CTX_SCRIPT}_create() { _meta $0
    tmux has-session -t miss &>/dev/null && return

    tmux new-session -d -s miss -n shy
    tmux split-window -p 30 -t miss:shy.1
    tmux split-window -h -t miss:shy.2

    tmux send-keys -t miss:shy.3 "tail -f bin/boot.log" Enter
    tmux send-keys -t miss:shy.2 "bin/ice.sh start serve shy" Enter
    tmux send-keys -t miss:shy.1 "vim" Enter
}
${ISH_CTX_SCRIPT}_attach() { _meta $0
    script create
    tmux attach-session -t miss
}

