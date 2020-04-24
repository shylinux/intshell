#!/bin/sh

require as cli base/cli/cli.sh

${ISH_CTX_SCRIPT}_init() {
    ish_cli_alias t "tmux attach"
    ish_cli_alias ta "tmux attach -t"
    ish_cli_alias ts "tmux new-session -s"
    ish_cli_alias tl "tmux list-sessions"
}
${ISH_CTX_SCRIPT}_sessions() {
    if [ "$1" = "" ]; then
        [ "$TMUX" = "" ] && tmux list-sessions || tmux choose-session
        return
    fi
    [ "$TMUX" = "" ] && tmux attach-session $1 || tmux switch-client -t $1
}
${ISH_CTX_SCRIPT}_windows() { tmux list-windows }
${ISH_CTX_SCRIPT}_panes() { tmux list-panes }

${ISH_CTX_SCRIPT}_split() {
    local target=$(tmux split-window -dP)
    tmux send-key -t $target "$@"
}

${ISH_CTX_SCRIPT}_init
