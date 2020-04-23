#!/bin/sh

ISH_LOG=${ISH_LOG:="/dev/null"}
ISH_ERR=${ISH_ERR:="/dev/stderr"}
ISH_PATH=${ISH_PATH:="$PWD/.ish/pluged"}
ISH_ROOT=${ISH_ROOT:="$HOME/.ish/pluged"}
ISH_HUB=${ISH_HUB:="github.com"}
ISH_FTP=${ISH_FTP:="https|http"}
ISH_INIT=${ISH_INIT:="init.sh"}
ISH_EXIT=${ISH_EXIT:="exit.sh"}
ISH_TYPE=${ISH_TYPE:=".sh"}
ISH_PRE=${ISH_PRE:="ish"}
ISH_ORDER=${ISH_ORDER:=0}

ISH_LOG=/dev/stderr
ish_log() { echo $* >$ISH_LOG; }
ish_err() { echo $* >$ISH_ERR; }

require_help() {
    echo "usage: require [as name] [mod] file..."
    echo "usage: auto download and load script"
    echo "usage: local mod: is dir in $ISH_PATH/ or ${ISH_PATH%/*}/"
    echo "usage: remote mod: is github repos, will auto download into $ISH_PATH/pluged/"
    echo "usage: as name: will add the prefix ${ISH_PRE}_name_ to all function and variable in the script "
    echo "usage: file: is file path in the mod"
}
require() {
    # 解析参数
    local name=$1 mod=$1 file=$ISH_INIT
    [ -z "$1" ] && echo $ISH_SCRIPT && return
    [ "$1" = "as" ] && name=$2 && mod=$3 && shift 3 || shift
    [ -z "$1" ] || file="$@"
    ish_log $0 $mod $file

    # 下载脚本
    local p="${mod%%/*}" && p=${p%:} && case "$p" in
        ${ISH_FTP}) local pp=$(_name $mod); [ -f "$ISH_ROOT/$pp/$file" ] || [ -f "$ISH_PATH/$pp/$file" ] || if true; then
                    mkdir -p $ISH_PATH/$pp && wget $mod/$file -O "$ISH_PATH/$pp/$file"
                fi; mod=$pp;;
        $ISH_HUB) [ -d "$ISH_ROOT/$mod/.git" ] || [ -d "$ISH_PATH/$mod/.git" ] || if true; then
                    git clone https://$mod $ISH_PATH/$mod
                fi;;
    esac

    # 加载脚本
    [ -f "$mod" ] && _load $mod || for p in $ISH_PATH $ISH_ROOT; do
        [ -f "${p%/*}/$mod" ] && _load ${p%/*}/$mod/$i && break
        [ -f "$p/$mod" ] && _load $p/$mod/$i && break
        [ -d "$p/$mod" ] && for i in $file; do
            ISH_MODULE=$(_name ish_${name}) ISH_SCRIPT=$(_name ish_${name}__${i%%.*}) _load $p/$mod/$i
        done && break
        [ "$ISH_PATH" = "$ISH_ROOT" ] && break
    done
}
module() { # 模块接口
    case "$1" in
        get|set|def) local op=$1 && shift && _conf $op $ISH_MODULE "$@";;
        *) local fun=$1 && shift && _conf run ${ISH_MODULE}_$fun "$@";;
    esac
}
script() { # 脚本接口
    case "$1" in
        get|set|def) local op=$1 && shift && _conf $op $ISH_SCRIPT "$@";;
        run)
            local mod=$2 file=$3 fun=$4 && shift 4
            local name=ish_$(_name ${mod}__${file%%.*}_${fun})
            declare -f $name >/dev/null || require ${mod} ${file}${ISH_TYPE}
            ISH_MODULE=ish_$(_name ${mod}) ISH_SCRIPT=ish_$(_name ${mod}__${file%%.*}) _conf run $name "$@"
            ;;
        *) local fun=$1 && shift && _conf run ${ISH_SCRIPT}_$fun "$@";;
    esac
}
object() { # 对象接口
    case "$1" in
        get|set|def) local op=$1 && shift && _conf $op $ISH_OBJECT "$@";;
        new) let ISH_ORDER=$ISH_ORDER+1 && echo ish_object_$ISH_ORDER;;
        *) local fun=$1 && shift 1 && _conf run ${ISH_OBJECT}_${fun} "$@"
    esac
}

_meta() {
    local meta="$*"
    ISH_MODULE=${meta/__*/} && [ "$meta" = "$ISH_MODULE" ] && ISH_MODULE=${meta%_*}
    ISH_SCRIPT=${meta%_*}
}
_name() {
    local name="$*"
    name=${name//\/\//\/}
    name=${name//:/}
    name=${name//./_} && name=${name//\//_} && name=${name//\ /_}
    echo $name
}
_eval() {
    ish_log "eval" "$*" && eval "$*"
}
_conf() {
    ish_log "conf $*"
    case "$1" in
        get) _eval "[ -z \"\$${2}_$3\" ] && ${2}_$3=\"$4\"; echo \$${2}_$3";;
        set) [ "$4" = "" ] && _eval "${2}_${3}=\"$5\"" || _eval "${2}_${3}=\"$4\"" ;;
        def) _eval "[ \"\$${2}_${3}\" = \"\" ] && ${2}_${3}=$4";;
        run) local func=$2 && shift 2
            ish_log "run" $func
            $func "$@"
    esac
}
_load() {
    [ -f "$1" ] || return
    ish_log "source" "\e[32m$*\e[0m"
    local back=$PWD pre=$1 && shift
    cd ${pre%/*} && ish_log "pwd" $PWD
    source ${pre##*/} "$@" >/dev/null
    cd $back
}
_plug() {
    for p in $ISH_ROOT $ISH_PATH; do
        local what=$p
        [ -d "$what" ] && for hub in $what/*; do
            case "${hub##*/}" in
                $ISH_HUB)
                    for repos in $hub/*/*; do
                        require ${repos#$what/} $1
                    done;;
                *) require ${hub#$what/} $1
            esac
        done
    done
}
_init() {
    ISH_OBJECT=$(object new)
    _plug $ISH_INIT
}
_exit() {
    ISH_OBJECT=$(object new)
    _plug $ISH_EXIT
    for fun in `declare -f|grep -o -e '^ish_[a-z_]\+_exit'`; do $fun; done
}
_init; trap _exit EXIT
ish() {
    local key=$1 && shift && local mod=${key%/*} file=${key##*/}
    file=${file//./\/} && script run ${mod} ${file%/*} ${file##*/} $@
}
