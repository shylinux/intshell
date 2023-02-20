#!/bin/sh

ish_sys_path_create() {
    local target=$1 && [ -d ${target%/*} ] && return
    [ ${target%/*} != ${target} ] && mkdir -p ${target%/*} || return 0
}
ish_sys_path_insert() {
    for p in "$@"; do
        echo $PATH| grep "$p" &>/dev/null || export PATH=$p:$PATH
    done
}
ish_sys_path_load() {
    local path=${CTX_ROOT:=$PWD}
    for line in `cat ${path}/etc/path 2>/dev/null`; do
        if echo $line| grep -v "^/" &>/dev/null; then line=$path/$line; fi
        ish_sys_path_insert $line
    done
    local path=$PWD
    for line in `cat ${path}/etc/path 2>/dev/null`; do
        if echo $line| grep -v "^/" &>/dev/null; then line=$path/$line; fi
        ish_sys_path_insert $line
    done
}
ish_sys_file_size() {
    local size=`ls -s $1 2>/dev/null| grep -o "[0-9]*"|head -n1`
    [ "$size" = "" ] && size=0; echo $size
}
ish_sys_file_create() {
    [ -e $1 ] && return || ish_log_debug -g "create file ${PWD} $1"
    ish_sys_path_create $1 && cat > $1
}
ish_sys_link_create() {
    [ -z "$2" ] && return
    [ -e "$1" ] && return || ish_log_debug -g "create link $1 <= $2"
    ish_sys_path_create $1 && ln -s $2 $1
}

