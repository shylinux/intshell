#!/bin/sh

ISH_LOG=${ISH_LOG:="/dev/null"}
ISH_PATH=${ISH_PATH:="$PWD/.ish/pluged"}
ISH_ROOT=${ISH_ROOT:="$HOME/.ish/pluged"}
ISH_HUB=${ISH_HUB:="github.com"}
ISH_FTP=${ISH_FTP:="https|http"}
ISH_INIT=${ISH_INIT:="init.sh"}
ISH_EXIT=${ISH_EXIT:="exit.sh"}
ISH_ORDER=${ISH_ORDER:=0}

ISH_LOG=/dev/stderr
ish_log() { echo $* >$ISH_LOG; }

require() {
    # 解析参数
    local name=$1 init=$ISH_INIT
    [ -z "$1" ] && echo $ISH_SCRIPT && return || shift
    [ -z "$1" ] || init="$@"
    ish_log $0 $name $init

    # 下载脚本
    local p="${name%%/*}" && p=${p%:} && case "$p" in
        ${ISH_FTP}) local pp=$ISH_PATH/$(_name $name)
            if ! [ -f $pp/$init ]; then mkdir -p $pp && wget $name/$init -O $pp/$init; fi
            name=$(_name $name) ;;
        $ISH_HUB) [ -d "$ISH_PATH/$name/.git" ] || git clone https://$name $ISH_PATH/$name;;
    esac

    # 加载脚本
    for p in $ISH_PATH $ISH_ROOT; do
        [ -d "$p/$name" ] && for i in $init; do
            ISH_MODULE=$(_name ish_${name}_) ISH_SCRIPT=$(_name ish_${name}__${i%%.*}) _load $p/$name/$i
        done && break
    done
}
module() { # 模块接口
    case "$1" in
        get) _conf get $ISH_MODULE "$2" "$3";;
        set) _conf set $ISH_MODULE "$2" "$3";;
        *)
            local mod=$1 fun=$2 && shift 2
            ISH_MODULE=ish_$(_name ${mod}_) _conf run ish_$(_name ${mod}_${fun}) "$@"
    esac
}
script() { # 脚本接口
    case "$1" in
        get) _conf get $ISH_SCRIPT "$2" "$3";;
        set) _conf set $ISH_SCRIPT "$2" "$3";;
        *)
            local mod=$1 file=$2 fun=$3 && shift 3
            local name=ish_$(_name ${mod}__${file%%.*}_${fun})
            declare -f $name >/dev/null || require ${mod} ${file}.sh
            ISH_MODULE=ish_$(_name ${mod}_) ISH_SCRIPT=ish_$(_name ${mod}__${file%%.*}) _conf run $name "$@"
    esac
}
object() { # 对象接口
    case "$1" in
        get) _conf get $ISH_OBJECT "$2" "$3";;
        set) _conf set $ISH_OBJECT "$2" "$3";;
        new) let ISH_ORDER=$ISH_ORDER+1 && echo ish_object_$ISH_ORDER;;
        *) local fun=$1 && shift 1 && _conf run ${ISH_OBJECT}_${fun} "$@"
    esac
}

_name() {
    local name="$*"
    name=${name//\/\//\/}
    name=${name//:/}
    name=${name//./_} && name=${name//\//_} && name=${name//\ /_}
    echo $name
}
_conf() {
    case "$1" in
        get) eval "[ -z \"\$${2}_$3\" ] && ${2}_$3=\"$4\"; echo \$${2}_$3";;
        set) eval "${2}_$3=\"$4\"";;
        run) local func=$2 && shift 2
            ish_log "run" $func
            $func "$@"
    esac
}
_load() {
    [ -f "$1" ] || return
    ish_log "source" "\e[32m$*\e[0m"
    local back=$PWD pre=$1
    cd ${pre%/*} && ish_log "pwd" $PWD
    source "$@" >/dev/null
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
}
_init && trap _exit EXIT
ish() {
    local key=$1 && shift && local mod=${key%/*} file=${key##*/}
    file=${file//./\/} && script ${mod} ${file%/*} ${file##*/} $@
}
