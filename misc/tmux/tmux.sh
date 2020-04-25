#!/bin/sh

ish_ctx_cli_tmux_init() {
    ish_ctx_cli_alias t "tmux attach"
    ish_ctx_cli_alias ta "tmux attach -t"
    ish_ctx_cli_alias ts "tmux new-session -s"
    ish_ctx_cli_alias tl "tmux list-sessions"
}
ish_ctx_cli_tmux_sessions() {
    if [ "$1" = "" ]; then
        [ "$TMUX" = "" ] && tmux list-sessions || tmux choose-session
        return
    fi
    [ "$TMUX" = "" ] && tmux attach-session $1 || tmux switch-client -t $1
}
ish_ctx_cli_tmux_windows() { tmux list-windows; }
ish_ctx_cli_tmux_panes() { tmux list-panes; }

ish_ctx_cli_tmux_split() {
    local target=$(tmux split-window -dP)
    tmux send-key -t $target "$@"
}

# ish_ctx_cli_tmux_init
