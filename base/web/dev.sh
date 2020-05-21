#!/bin/sh

ish_ctx_dev_sid=${ish_ctx_dev_sid:=""}
ish_ctx_dev_request() {
    local url=$ISH_CONF_DEV/code/zsh/$1 && shift
    ish_web_request "$url" "$@" pwd "${PWD}" sid "$ish_ctx_dev_sid" SHELL $SHELL
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

ish_ctx_dev_sync_history() {
    ctx_end=`history|tail -n1|awk '{print $1}'`
    ctx_begin=${ctx_begin:=$ctx_end}
    ctx_count=`expr $ctx_end - $ctx_begin`
    ish_log_debug "sync $ctx_begin-$ctx_end count $ctx_count to $ctx_dev"
    HISTTIMEFORMAT="%F %T " history|tail -n $ctx_count |while read line; do
        ish_ctx_dev_request sync cmds history arg "$line" >/dev/null
    done
    ctx_begin=$ctx_end
}

ish_ctx_dev_init() {
    ish_ctx_dev_login
    if bind &>/dev/null; then
        # bash
        bind -x '"\C-G\C-G":ish_ctx_dev_sync_history'
    elif bindkey &>/dev/null; then
        # zsh
        bindkey -s '\C-G\C-G' 'ish_ctx_dev_sync_history\n'
    fi
}
ish_ctx_dev_exit() {
    ish_ctx_dev_sync_history
    ish_ctx_dev_logout
}
ish_ctx_dev_init

