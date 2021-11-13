#!/bin/sh

ish_sys_dev_sid=${ish_sys_dev_sid:=""}
ish_sys_dev_sid() { echo $ish_sys_dev_sid; }
ish_sys_dev_request() {
    local url=$ctx_dev/code/bash/$1 && shift
    ish_sys_web_request "$url" "$@" pwd "${PWD}" sid "$ish_sys_dev_sid"
}
ish_sys_dev_source() {
    local ctx_temp=$(mktemp); ish_sys_dev_request "$@" >$ctx_temp && source $ctx_temp "$@"
}
ish_sys_dev_configs() {
    ish_sys_dev_request configs
}
ish_sys_dev_qrcode() {
    ish_sys_dev_request qrcode text "$@"
}
ish_sys_dev_logout() {
    ish_sys_dev_request sess cmds logout 2>/dev/null && ish_sys_dev_sid=""
}
ish_sys_dev_login() {
    ish_sys_dev_sid=$(ish_sys_dev_request sess username "$(whoami)" hostname "$(hostname)" pid "$$")
}

ish_sys_dev_upload() {
    [ "$#" = "0" ] && ish_sys_dev_request download && return
    local file=$1 && shift && ish_sys_dev_request upload upload "@$file" $@
}
ish_sys_dev_download() {
    [ "$#" = "0" ] && ish_sys_dev_request download && return
    ish_sys_dev_request download cmds $@
}

ish_sys_dev_trash=${ish_sys_dev_trash:=~/trash}
ish_sys_dev_trash() {
    local from=$PWD/$1 to=$ish_sys_dev_trash/$(ish_sys_date_filename)-`echo $PWD/$1| tr '/' '_'`
    local size=`du -sb $from 2>/dev/null |cut -f1 2>/dev/null`
    ish_sys_dev_request trash cmds insert size "$size" from "$from" to "$to" &>/dev/null
    mkdir -p $ish_sys_dev_trash &>/dev/null; mv $from $to
}

ish_sys_dev_favor() {
    if [ -z "$1" ]; then ish_sys_dev_request favor; return; fi
    ish_sys_dev_request favor cmds export zone "$1" name "$2"
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
ish_sys_dev_exit() {
    ish_sys_dev_logout
}
ish_sys_dev_init() {
    ish_sys_dev_login
    if bind &>/dev/null; then # bash
        trap ish_sys_dev_exit EXIT
        trap ish_sys_dev_sync DEBUG

    elif bindkey &>/dev/null; then # zsh
        echo > /dev/null
    fi
}
ish_sys_dev_init

ish_sys_dev_run() {
    local cmd="run/action/run"; for key in "$@"; do cmd=$cmd"/"$key; done
    local res=$(mktemp); ish_sys_dev_request $cmd >$res
    if head -n1 $res|grep "warn: not login" &>/dev/null; then
        local url=$ctx_dev/chat/cmd/web.code.bash.grant/$ish_sys_dev_sid
        ish_sys_dev_qrcode $url
        echo
        return
    elif head -n1 $res|grep "warn: not right" &>/dev/null; then
        local url=$ctx_dev/chat/cmd/web.code.bash.grant/$ish_sys_dev_sid
        ish_sys_dev_qrcode $url
        echo
        return
    fi

    local cmd="run/action/command"; for key in "$@"; do cmd=$cmd"/"$key; done
    local ctx_temp=$(mktemp); ish_sys_dev_request $cmd >$ctx_temp && source $ctx_temp $res
}
