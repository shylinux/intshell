#!/bin/sh

ish_ctx_dev_sid=${ish_ctx_dev_sid:=""}
ish_ctx_dev_request() {
    local url=$ctx_dev/code/zsh/$1 && shift
    ish_web_request "$url" "$@" pwd "${PWD}" pid "$$" sid "$ish_ctx_dev_sid" SHELL "$SHELL"
}
ish_ctx_dev_login_list() {
    ish_help_show dev $ctx_dev sid $ish_ctx_dev_sid
}
ish_ctx_dev_login() {
    ish_ctx_dev_sid=$(ish_ctx_dev_request sess sid "$ish_ctx_dev_sid" username "$(whoami)" hostname "$(hostname)" pid "$$" pwd "$(pwd)")
    ish_ctx_dev_login_list
}
ish_ctx_dev_logout() {
    ish_ctx_dev_request sess cmds logout 2>/dev/null && ish_ctx_dev_sid=""
}

zshaddhistory() {
    local name=`history|tail -n1|grep -o "[0-9]\+\ "`
    [ -n "$name" ] && ((name = name + 1)) && ish_ctx_dev_request sync cmds history arg "$name `date +"%Y-%m-%d %H:%M:%S"` $1" >/dev/null
}
ish_ctx_dev_sync() {
    local cmd=`HISTTIMEFORMAT="%F %T " history|tail -n1`
    [ -n "$cmd" ] && ish_ctx_dev_request sync cmds history arg "$cmd" >/dev/null
}
ish_ctx_dev_init() {
    ish_ctx_dev_login
    if bind &>/dev/null; then
        # bash
        trap ish_ctx_dev_sync DEBUG

    elif bindkey &>/dev/null; then
        # zsh
        echo > /dev/null
    fi
}
ish_ctx_dev_exit() {
    ish_ctx_dev_logout
}
ish_ctx_dev_init

ish_ctx_dev_upload_help() {
    ish_help_show usage "ish_ctx_dev_upload file"
}
ish_ctx_dev_upload() {
    [ "$1" = "" ] && ish_ctx_dev_upload_help && return
    local file=$1 && shift
    ish_ctx_dev_request upload upload "@$file" $@
}
ish_ctx_dev_download_help() {
    ish_help_show usage "ish_ctx_dev_download file"
}
ish_ctx_dev_download() {
    [ "$#" = "0" ] && ish_ctx_dev_request download && return
    ish_ctx_dev_request download cmds $@
}

