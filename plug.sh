#!/bin/sh

ISH_CONF_ERR=${ISH_CONF_ERR:="/dev/stderr"}
ISH_CONF_LOG=${ISH_CONF_LOG:="/dev/stderr"}
# ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="debug test"}
ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="require source debug test"}
ISH_CONF_COLOR=${ISH_CONF_COLOR:="true"}

ISH_CONF_PATH=${ISH_CONF_PATH:="$PWD/.ish/pluged"}
ISH_CONF_ROOT=${ISH_CONF_ROOT:="$HOME/.ish/pluged"}
ISH_CONF_HUB=${ISH_CONF_HUB:="github.com"}
ISH_CONF_FTP=${ISH_CONF_FTP:="https|http"}
ISH_CONF_HELP=${ISH_CONF_HELP:="help"}
ISH_CONF_TEST=${ISH_CONF_TEST:="test"}
ISH_CONF_INIT=${ISH_CONF_INIT:="init"}
ISH_CONF_EXIT=${ISH_CONF_EXIT:="exit"}
ISH_CONF_TYPE=${ISH_CONF_TYPE:=".sh"}
ISH_CONF_PRE=${ISH_CONF_PRE:="ish"}

ISH_CTX_ORDER=${ISH_CTX_ORDER:=0}
ISH_CTX_MODULE=${ISH_CONF_PRE}_ctx
ISH_CTX_SCRIPT=${ISH_CTX_MODULE}
ISH_CTX_OBJECT=${ISH_CTX_MODULE}_obj_0

ISH_CTX_ERR_COUNT=0
ISH_LOG_ERR=${ISH_CONF_ERR}
ISH_LOG_INFO=${ISH_CONF_LOG}
ish_log() {
    [ "${ISH_CONF_LEVEL}" = "" ] && echo $* >$ISH_LOG_INFO
    for l in $(echo $ISH_CONF_LEVEL); do
        [ "$l" = $1 ] && echo $* >$ISH_LOG_INFO
    done
    return 0
}
ish_log_err() {
    let ISH_CTX_ERR_COUNT=$ISH_CTX_ERR_COUNT + 1
    echo $* >$ISH_LOG_ERR
}
ish_log_eval() { ish_log "eval" $* }
ish_log_conf() { ish_log "conf" $* }
ish_log_test() { ish_log "test" $* }
ish_log_debug() { ish_log "debug" $* }
ish_log_source() { ish_log "source" $* }
ish_log_require() { ish_log "require" $* }

require_help() {
    echo "usage: $(_color green require \[as name\] file...)"
    echo "       source script $(_color underline file) as $(_color underline name)"
    echo
    echo "usage: $(_color yellow require \[as name\] mod file...)"
    echo "       auto download $(_color underline mod) as $(_color underline name) and source script $(_color underline file)"
    echo
    echo "usage: $(_color red require \[as name\] mod)"
    echo "       auto download $(_color underline mod) as $(_color underline name) and source $(_color bold \${ISH_CONF_INIT}\${ISH_CONF_TYPE}) file"
    echo
}
require_test() {
    ISH_CTX_MODULE=ish_ctx ISH_CTX_SCRIPT=ish_ctx ish_test "require base/cli/os.sh"\
        "ish_ctx_os_system" "uname -o"

    ish_test "require github.com/shylinux/shell base/cli/date.sh" \
        "ish_ctx_date_hour" "date +%H"

    ish_test "require as some github.com/shylinux/shell base/cli/info.sh" \
        "ish_some_os_system" "uname -o"

    ish_test "require github.com/shylinux/shell" \
        "ish_ctx_os_system" "uname -o"
}
require() {
    # 解析参数
    [ -z "$1" ] && require_help && return
    local name=${ISH_CTX_MODULE#ish_} && [ "$1" = "as" ] && name=$2 && shift 2
    local mod=$1 file=$ISH_CONF_INIT$ISH_CONF_TYPE && shift && [ -z "$1" ] || file="$@"
    ish_log_require as $name $mod $file

    # 下载脚本
    local p="${mod%%/*}" && p=${p%:} && case "$p" in
        ${ISH_CONF_FTP}) local pp=$(_name $mod); [ -f "$ISH_CONF_ROOT/$pp/$file" ] || [ -f "$ISH_CONF_PATH/$pp/$file" ] || if true; then
                    mkdir -p $ISH_CONF_PATH/$pp && wget $mod/$file -O "$ISH_CONF_PATH/$pp/$file"
                fi; mod=$pp;;
        $ISH_CONF_HUB) [ -d "$ISH_CONF_ROOT/$mod/.git" ] || [ -d "$ISH_CONF_PATH/$mod/.git" ] || if true; then
                    git clone https://$mod $ISH_CONF_PATH/$mod
                fi;;
    esac

    # 加载脚本
    [ -f "$mod" ] && __load "$name" $mod || for p in $ISH_CONF_PATH $ISH_CONF_ROOT; do
        [ -f "${p%/*}/$mod" ] && __load "$name" ${p%/*}/$mod && break
        [ -f "$p/$mod" ] && __load "$name" $p/$mod && break

        [ -d "$p/$mod" ] && for i in $file; do
            __load "${name}" "$p/$mod/$i"
        done && break
        [ "$ISH_CONF_PATH" = "$ISH_CONF_ROOT" ] && break
    done
}

ish_ctx_module() { # 模块接口
    case "$1" in
        get|set|def) local op=$1 && shift && _conf $op $ISH_CTX_MODULE "$@";;
        *) local fun=$1 && shift && _conf run ${ISH_CTX_MODULE}_$fun "$@";;
    esac
}
ish_ctx_script() { # 脚本接口
    case "$1" in
        get|set|def) local op=$1 && shift && _conf $op $ISH_CTX_SCRIPT "$@";;
        run)
            local mod=$2 file=$3 fun=$4 && shift 4
            local name=${ISH_CTX_SCRIPT}_$(_name ${fun})
            declare -f $name >/dev/null || require ${mod} ${file}${ISH_CONF_TYPE}
            _conf run $name "$@"
            ;;
        *) local fun=$1 && shift && _conf run ${ISH_CTX_SCRIPT}_$fun "$@";;
    esac
}
ish_ctx_object() { # 对象接口
    case "$1" in
        get|set|def) local op=$1 && shift && _conf $op $ISH_CTX_OBJECT "$@";;
        new) let ISH_CTX_ORDER=$ISH_CTX_ORDER+1 && echo ish_ctx_object_$ISH_CTX_ORDER;;
        *) local fun=$1 && shift 1 && _conf run ${ISH_CTX_OBJECT}_${fun} "$@"
    esac
}

_meta() {
    ISH_CTX_MODULE=$(_name "$*") && while [ "$ISH_CTX_MODULE" != "" ]; do
        ISH_CTX_MODULE=${ISH_CTX_MODULE%_*}
        declare -f ${ISH_CTX_MODULE}_${ISH_CONF_EXIT} >/dev/null && break
    done
    [ "$ISH_CTX_MODULE" = "$ISH_CONF_PRE" ] && ISH_CTX_MODULE=${ISH_CTX_MODULE}_ctx
    ISH_CTX_SCRIPT=$ISH_CTX_MODULE
}
_name() {
    local name="$*"
    echo ${name//[^a-zA-Z0-9_]/_}
}
_color() {
    [ "$ISH_CONF_COLOR" != "true" ] && echo "$*" && return
    local prefix="" && for c in $(echo $1); do
        prefix=$prefix$(_eval "echo \"\$ISH_CONF_COLOR_${c}\"")
    done && shift
    echo "$prefix$*\e[0m"
}
_eval() {
    ish_log_eval "$*" && eval "$*"
}
_conf() {
    ish_log_conf "$*" && case "$1" in
        get) _eval "[ -z \"\$${2}_$3\" ] && ${2}_$3=\"$4\"; echo \$${2}_$3";;
        set) [ "$4" = "" ] && _eval "${2}_${3}=\"$5\"" || _eval "${2}_${3}=\"$4\"" ;;
        def) _eval "[ \"\$${2}_${3}\" = \"\" ] && ${2}_${3}=$4";;
        run) local func=$2 && shift 2 
            $func "$@"
            ;;
    esac
}
_load() {
    local pre=$1 && shift
    ish_log_source "$(_color green $pre "$@") -> $ISH_CTX_SCRIPT"
    source ${pre##*/} "$@" >/dev/null
}
__load() {
    local name=$1 && shift 1 && local back=$PWD pre=$1 && [ -f "$pre" ] || return
    [ -d "${pre%/*}" ] && cd ${pre%/*}
    ISH_CTX_MODULE=$(_name ish_${name}) ISH_CTX_SCRIPT=$(_name ish_${name}) _load "$@"
    cd $back
}

_plug() {
    ISH_CTX_OBJECT=$(ish_ctx_object new)
    for p in $ISH_CONF_ROOT $ISH_CONF_PATH; do
        local what=$p && [ -d "$what" ] && for hub in $what/*; do
            case "${hub##*/}" in
                $ISH_CONF_HUB)
                    for repos in $hub/*/*; do
                        require ${repos#$what/} $1${ISH_CONF_TYPE}
                    done;;
                *) require ${hub#$what/} $1${ISH_CONF_TYPE}
            esac
        done
        [ "$ISH_CONF_ROOT" = "$ISH_CONF_PATH" ] && break
    done
    for fun in `declare -f|grep -o -e "^ish_[a-z_]\+_$1"`; do $fun; done
}
_help() { _plug $ISH_CONF_HELP }
_test() { _plug $ISH_CONF_TEST }
_init() { _plug $ISH_CONF_INIT }
_exit() { _plug $ISH_CONF_EXIT }
# _init; trap _exit EXIT

ish_help() {
    echo "usage: $(_color green ish mod/file_fun arg...)"
    echo "       auto download $(_color underline mod) and auto load $(_color underline file) and then call the $(_color underline fun)"
    echo "       demo: ish github.com/shylinux/shell/base.cli.os_os_system"
    echo
    echo "usage: $(_color cyan ish mod key arg...)"
    echo "       get module of $(_color underline key)"
    echo
    echo "usage: $(_color cyan ish run fun arg...)"
    echo "       call function $(_color underline fun) in the script $(_color bold \${ISH_CTX_SCRIPT})"
    echo
    echo "usage: $(_color blue ish get key \[value\])"
    echo "       get value of variable $(_color underline key) in the script $(_color bold \${ISH_CTX_SCRIPT}) or default $(_color underline value)"
    echo
    echo "usage: $(_color purple ish set key value)"
    echo "       set $(_color underline value) of variable $(_color underline key) in the script $(_color bold \${ISH_CTX_SCRIPT})"
    echo
    echo "usage: $(_color red ish def key value)"
    echo "       set default $(_color underline value) of variable $(_color underline key) in the script $(_color bold \${ISH_CTX_SCRIPT})"
}
ish() {
    [ "$1" = "" ] && ish_help && return
    case "$1" in; get|set|def) ish_ctx_script "$@"; return;; esac
    case "$1" in; run) shift && ish_ctx_script "$@"; return;; esac
    case "$1" in; mod) shift && _meta "$@"; return;; esac

    local fun=${ISH_CTX_SCRIPT}_$(_name $1)
    declare -f $fun >/dev/null && shift && $fun $@ && return

    local mod=$1 && shift && local file=${mod##*/} && mod=${mod%/$file}
    [ "$mod" = "$file" ] && mod=""
    local fun=${file#*_} && [ "$fun" = "$file" ] && fun="" || file=${file%_$fun}
    file=${file//./\/}
    [ "$mod" != "" ] && ISH_CTX_MODULE=$(_name ish_$mod) ISH_CTX_SCRIPT=$(_name ish_$mod) ish_ctx_script run "${mod}" "${file}" "${fun}" $@ || ish_ctx_script run "${mod}" "${file}" "${fun}" $@
}
