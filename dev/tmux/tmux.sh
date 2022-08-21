#!/bin/bash

ish_dev_tmux_prepare() {
    local from=$PWD/usr/intshell/dev/tmux

	if [ "`tmux -V`" = "tmux 1.8" ]; then
		ish_sys_link_create ~/.tmux_local $from/tmux-1.8.conf
	else
		ish_sys_link_create ~/.tmux_local $from/tmux_local.conf
	fi
    ish_sys_link_create ~/.tmux.conf $from/tmux.conf
}
ish_dev_tmux_session() {
	local tmux_cmd="tmux -S bin/tmux.socket -f etc/tmux.conf"
    local session=miss && [ -s "$1" ] && session=$1 && shift

    if $tmux_cmd has-session -t $session; then
        $tmux_cmd attach -t $session
    else
        $tmux_cmd new-session -s $session
    fi
}
