#!/bin/sh

ish_ctx_cli_shell() {
    cat /proc/$$/cmdline|sed 's/-//'
}
ish_ctx_cli_jobs() {
    local out=$1 && shift && local err=$1 && shift
    ish_log_debug "pid: $? out: $out err: $err cmd: $@"
    eval "eval $@ >>$out 2>>$err \&"
}

ish_ctx_cli_alias() {
    [ "$#" = "0" ] && alias && return
    [ "$#" = "1" ] && alias $1 && return

    ish_log_info $1 $2
    alias $1=$2
}

