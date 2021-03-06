#!/bin/bash

tmux_cmd="tmux -S bin/tmux.socket -f etc/tmux.conf"
session=miss && [ -s "$1" ] && session=$1 && shift

if $tmux_cmd has-session -t $session; then
    $tmux_cmd attach -t $session
else
    $tmux_cmd new-session -s $session
fi
