#!/bin/sh

ish_ctx_dev_tmux_prepare() {
    ish_miss_create_link ~/.tmux.conf $PWD/usr/intshell/misc/tmux/tmux.conf
}

ish_ctx_dev_tmux_session() {
    local tmux_cmd="tmux -S bin/tmux.socket -f etc/tmux.conf"
    local session=miss && [ -s "$1" ] && session=$1 && shift

    if $tmux_cmd has-session -t $session; then
        $tmux_cmd attach -t $session
    else
        $tmux_cmd new-session -s $session
    fi
}
