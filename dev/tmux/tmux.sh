#!/bin/bash

ish_dev_tmux_prepare() {
    ish_sys_link_create ~/.tmux.conf $PWD/usr/intshell/dev/tmux/tmux.conf
	if [ "`tmux -V`" = "tmux 1.8" ]; then
		ish_sys_link_create ~/.tmux_local $PWD/usr/intshell/dev/tmux/tmux-1.8.conf
	else
		ish_sys_link_create ~/.tmux_local $PWD/usr/intshell/dev/tmux/tmux_local.conf
	fi

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
