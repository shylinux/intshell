#!/bin/sh

ish_ctx_dev_sid=${ish_ctx_dev_sid:=""}
ish_ctx_dev_request() {
    local url=$ISH_CONF_DEV/code/zsh/$1 && shift
    ish_web_request "$url" "$@" pwd "${PWD}" sid "$ish_ctx_dev_sid" SHELL $SHELL
    echo "$@" >> hi.log
}

ish_ctx_dev_help() {
    ish_ctx_dev_upload_help
    ish_ctx_dev_download_help
}
ish_ctx_dev_test() {
    echo
}
ish_ctx_dev_login_list() {
    ish_help_show \
        dev $ISH_CONF_DEV \
        sid $ish_ctx_dev_sid
}
ish_ctx_dev_login() {
    [ "$ish_ctx_dev_sid" = "" ] || return
    ish_ctx_dev_sid=$(ish_ctx_dev_request login)
    ish_log_info op login dev "$ISH_CONF_DEV" sid "$ish_ctx_dev_sid"
    ish_ctx_dev_login_list
}
ish_ctx_dev_logout() {
    ish_ctx_dev_request logout 2>/dev/null
    ish_log_info op logout dev "$ISH_CONF_DEV" sid "$ish_ctx_dev_sid"
    ish_ctx_dev_sid=""
}

ish_ctx_dev_ice() {
    ish_ctx_dev_request ish sub "$*"
}

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

ish_ctx_dev_sync() {
    local cmd=`HISTTIMEFORMAT="%F %T " history|tail -n1`
    [ -n "$cmd" ] && ish_ctx_dev_request sync cmds history arg "$cmd" >/dev/null
}

ish_ctx_dev_init() {
    ish_ctx_dev_login
    if bind &>/dev/null; then
        # bash
        trap ish_ctx_dev_sync DEBUG

        # bind 'TAB:complete' 
        bind 'TAB:menu-complete' 

    elif bindkey &>/dev/null; then
        # zsh
        bindkey -s '\C-G\C-G' 'ish_ctx_dev_sync_history\n'
    fi
}
ish_ctx_dev_exit() {
    ish_ctx_dev_logout
}
ish_ctx_dev_init

