#!/bin/sh

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

