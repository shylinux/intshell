#!/bin/sh

alias t="tmux attach"

${ISH_SCRIPT}_tmux_sessions() {
    if [ "$1" = "" ]; then
        [ "$TMUX" = "" ] && tmux list-sessions || tmux choose-session
        return
    fi
    [ "$TMUX" = "" ] && tmux attach-session $1 || tmux switch-client -t $1
}
${ISH_SCRIPT}_tmux_windows() { tmux list-windows }
${ISH_SCRIPT}_tmux_panes() { tmux list-panes }

