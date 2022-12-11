#!/bin/sh

ish_sys_dev_sid=${ish_sys_dev_sid:=""}
ish_sys_dev_sid() { echo $ish_sys_dev_sid; }
ish_sys_dev_request() {
    local url=$ctx_dev/code/bash/$1 && shift
    ish_sys_web_request "$url" "$@" pwd "${PWD}" sid "$ish_sys_dev_sid" pod $ctx_pod
}
ish_sys_dev_source() {
    local ctx_temp=$(mktemp); ish_sys_dev_request "$@" >$ctx_temp && source $ctx_temp "$@"
}
ish_sys_dev_qrcode() {
    ish_sys_dev_request qrcode text "$@"
}
ish_sys_dev_logout() {
    ish_sys_dev_request sess/action/logout &>/dev/null && ish_sys_dev_sid=""
	[ -z "$ish_sys_dev_sid" ] && echo "logout success from $ctx_dev"
}
ish_sys_dev_login() {
    ish_sys_dev_sid=$(ish_sys_dev_request sess/ username "$(whoami)" hostname "$(hostname)" release "$(cat /etc/os-release|grep '^ID=')" pid "$$")
	[ -n "$ish_sys_dev_sid" ] && echo "login success into $ctx_dev"
}
ish_sys_dev_check() {
    ish_sys_dev_request run/action/check
}
ish_sys_dev_grant() {
    ish_sys_dev_qrcode $ctx_dev/chat/cmd/web.code.bash.grant/$ish_sys_dev_sid
}
ish_sys_dev_sync() {
	local cmd=$(HISTTIMEFORMAT="%F %T " history|tail -n1)
    [ -n "$cmd" ] && [ "$ish_sys_dev_sync_last" != "$cmd" ] && ish_sys_dev_request sync/action/history SHELL "$SHELL" arg "$cmd" >/dev/null
    ish_sys_dev_sync_last=$cmd
}
ish_sys_dev_favor() {
    if [ -z "$1" ]; then ish_sys_dev_request favor/; return; fi
    ish_sys_dev_request favor/action/export zone "$1" name "$2"
}
ish_sys_dev_trash=${ish_sys_dev_trash:=~/trash}
ish_sys_dev_trash() {
    local from=$PWD/$1 to=$ish_sys_dev_trash/$(ish_sys_date_filename)-$(echo $PWD/$1| tr '/' '_')
    local size=$(du -sb $from 2>/dev/null |cut -f1 2>/dev/null)
    ish_sys_dev_request trash/action/insert size "$size" from "$from" to "$to" &>/dev/null
    mkdir -p $ish_sys_dev_trash &>/dev/null; mv $from $to
}
ish_sys_dev_trash_list() {
    ish_sys_dev_request trash
}
ish_sys_dev_trash_revert() {
	if [ -n "$*" ]; then
    	ish_sys_dev_source trash/action/revert "$@"
	else
    	ish_sys_dev_request trash/
	fi
}
ish_sys_dev_upload() {
    [ "$#" = "0" ] && ish_sys_dev_request download && return
    local file=$1 && shift && ish_sys_dev_request upload upload "@$file" "$@"
}
ish_sys_dev_download() {
    [ "$#" = "0" ] && ish_sys_dev_request download && return
    ish_sys_dev_request download cmds $@
}
ish_sys_dev_configs() {
    ish_sys_dev_source configs
}
ish_sys_dev_exit() {
    ish_sys_dev_logout
}
ish_sys_dev_init() {
    ish_sys_dev_login
    if bind &>/dev/null; then # bash
		complete -F ish_sys_dev_complete ish_sys_dev_run
		complete -F ish_sys_dev_complete ice
        trap ish_sys_dev_sync DEBUG
        trap ish_sys_dev_exit EXIT
    fi
}
ish_sys_dev_complete() {
	local res=$(ish_sys_dev_request run/action/complete line "$COMP_LINE" cword "$COMP_CWORD" point "$COMP_POINT" words "$COMP_WORDS")
	COMPREPLY=($(compgen -W "$res" "${COMP_WORDS[${COMP_CWORD}]}"))
}
ish_sys_dev_run_preload=""
ish_sys_dev_run_prepare() {
    local cmd="run/action/command"; for key in "$@"; do cmd=$cmd"/"$key; done
    if [ "$ish_sys_dev_run_preload" = "" ]; then
        ish_sys_dev_run_preload=$(mktemp); ish_sys_dev_request $cmd >$ish_sys_dev_run_preload
    fi
    source $ish_sys_dev_run_preload $ish_sys_dev_run_output
}
ish_sys_dev_run_output=""
ish_sys_dev_run() {
    if [ "$*" = "" ]; then return; fi
    local cmd="run/action/run"; for key in "$@"; do cmd=$cmd"/"$key; done
    ish_sys_dev_run_output=$(mktemp); ish_sys_dev_request $cmd >$ish_sys_dev_run_output
    if head -n1 $ish_sys_dev_run_output|grep "not login: " &>/dev/null; then
        ish_sys_dev_login
    elif head -n1 $ish_sys_dev_run_output|grep "not right: " &>/dev/null; then
        ish_sys_dev_grant
    else
        ish_sys_dev_run_prepare "$@"
    fi
}
alias ice=ish_sys_dev_run
alias cmd=ish_sys_dev_run_command
zshaddhistory() {
    local index=`history|tail -n1|grep -o "[0-9]\+\ "`
    [ -n "$index" ] && [ "$ish_sys_dev_sync_last" != "$index" ] && ((index = index + 1)) && ish_sys_dev_request sync/action/history arg "$index $(date +"%Y-%m-%d %H:%M:%S") $1" >/dev/null
    ish_sys_dev_sync_last=$index
}
