#!/bin/sh

ish_sys_dev_sid=${ish_sys_dev_sid:=""}
ish_sys_dev_sid() { echo $ish_sys_dev_sid; }
ish_sys_dev_request() {
    local url=$ctx_dev/code/bash/$1 && shift
    ish_sys_web_request "$url" "$@" pwd "${PWD}" sid "$ish_sys_dev_sid"
}
ish_sys_dev_login() {
    ish_sys_dev_sid=$(ish_sys_dev_request sess username "$(whoami)" hostname "$(hostname)" pid "$$")
}
ish_sys_dev_logout() {
    ish_sys_dev_request sess cmds logout 2>/dev/null && ish_sys_dev_sid=""
}
# ish_sys_dev_login

ish_sys_dev_qrcode() {
    ish_sys_dev_request qrcode text "$@"
}
ish_sys_dev_favor() {
    if [ -z "$1" ]; then
        ish_sys_dev_request favor
    else
        ish_sys_dev_request favor cmds export tab "$1" note "$2"
    fi
}
ish_sys_dev_trash=${ish_sys_dev_trash:=~/trash}
ish_sys_dev_trash() {
    local size=`du -sb $from|cut -f1 2>/dev/null`
    local from=$PWD/$1 to=$ish_sys_dev_trash/`date +"%Y%m%d-%H%M%S"`-`echo $PWD/$1| tr '/' '_'`
    ish_sys_dev_request trash cmds insert hostname "$(hostname)" size "$size" from "$from" to "$to" &>/dev/null
    mkdir -p $ish_sys_dev_trash &>/dev/null; mv $from $to
}

zshaddhistory() {
    local name=`history|tail -n1|grep -o "[0-9]\+\ "`
    [ -n "$name" ] && [ "$ish_sys_dev_sync_last" != "$name" ] && ((name = name + 1)) && ish_sys_dev_request sync cmds history arg "$name `date +"%Y-%m-%d %H:%M:%S"` $1" >/dev/null
    ish_sys_dev_sync_last=$name
}
ish_sys_dev_sync() {
    local cmd=`HISTTIMEFORMAT="%F %T " history|tail -n1`
    [ -n "$cmd" ] && [ "$ish_sys_dev_sync_last" != "$cmd" ] && ish_sys_dev_request sync SHELL "$SHELL" cmds history arg "$cmd" >/dev/null
    ish_sys_dev_sync_last=$cmd
}
ish_sys_dev_init() {
    if bind &>/dev/null; then # bash
        return
        trap ish_sys_dev_sync DEBUG

    elif bindkey &>/dev/null; then # zsh
        echo > /dev/null
    fi
}
ish_sys_dev_exit() {
    ish_sys_dev_logout
}
# ish_sys_dev_init

ish_sys_dev_upload() {
    local file=$1 && shift
    ish_sys_dev_request upload upload "@$file" $@
}
ish_sys_dev_download() {
    [ "$#" = "0" ] && ish_sys_dev_request download && return
    ish_sys_dev_request download cmds $@
}

