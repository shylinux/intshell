#!/bin/sh

ish_ctx_dev_sid=""
ish_ctx_dev_request() {
    local url=$ISH_CONF_DEV$1 && shift
    ish_web_request "$url" "$@" pwd "${PWD}" sid "$ish_ctx_dev_sid"
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
    ish_ctx_dev_sid=$(ish_ctx_dev_request /code/zsh/login)
    ish_log_info op login dev "$ISH_CONF_DEV" sid "$ish_ctx_dev_sid"
    ish_ctx_dev_login_list
}
ish_ctx_dev_logout() {
    ish_ctx_dev_request /code/zsh/logout 2>/dev/null
    ish_log_info op logout dev "$ISH_CONF_DEV" sid "$ish_ctx_dev_sid"
    ish_ctx_dev_sid=""
}

ish_ctx_dev_ice() {
    ish_ctx_dev_request /code/zsh/ish sub "$*"
}


ish_ctx_dev_upload_help() {
    ish_help_show usage "ish_ctx_dev_upload file"
}
ish_ctx_dev_upload() {
    [ "$1" = "" ] && ish_ctx_dev_upload_help && return
    local file=$1 && shift
    ish_ctx_dev_request /code/zsh/upload upload "@$file" $@
}
ish_ctx_dev_download_help() {
    ish_help_show usage "ish_ctx_dev_download file"
}
ish_ctx_dev_download() {
    [ "$#" = "0" ] && ish_ctx_dev_request /code/zsh/download
    ish_ctx_dev_request /code/zsh/download cmds $@
}

ish_ctx_dev_init() {
    ish_ctx_dev_login
}
ish_ctx_dev_exit() {
    ish_ctx_dev_logout
}
ish_ctx_dev_init

