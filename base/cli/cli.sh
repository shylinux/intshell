#!/bin/sh

ish_ctx_cli_shell() {
    cat /proc/$$/cmdline|sed 's/-//'
}

ish_ctx_cli_alias() {
    ish_log "bench"
    echo "alias" "$1=$2"
    alias $1=$2
}

