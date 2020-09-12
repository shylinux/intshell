# intshell: 终端 神农架 整个脚本
# PMS: a plugin manger system
#
# 1.DOWNLOAD
# $ git clone https://github.com/shylinux/intshell ~/.ish
# $ source ~/.ish/plug.sh
# $ require_help
#
# 2.TEST
# $ require test.sh
# $ ish_test
#
# 3.HELP
# $ require show.sh
# $ ish_help_list
# $ ish_help_repos
# $ ish_help_script
# $ ish_help_require
# $ ish_help_ish

## 1.场景化 # {
ISH_CONF_ERR=${ISH_CONF_ERR:="/dev/stderr"}
ISH_CONF_LOG=${ISH_CONF_LOG:="/dev/stderr"}
ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="require source debug test"}
# ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="info debug test"}

ISH_CONF_TASK=$PWD
ISH_CONF_WORK=${ISH_CONF_WORK:=~/work}
ISH_CONF_MISS=${ISH_CONF_MISS:="etc/miss.sh"}

ISH_CONF_PATH=$PWD/.ish/pluged
ISH_CONF_ROOT=${ISH_CONF_ROOT:="$HOME/.ish/pluged"}
ISH_CONF_FTP=${ISH_CONF_FTP:="https|http"}
ISH_CONF_HUB=${ISH_CONF_HUB:="github.com"}
ISH_CONF_HUB_PROXY=${ISH_CONF_HUB_PROXY:="https://"}

ISH_CONF_HELP=${ISH_CONF_HELP:="help"}
ISH_CONF_TEST=${ISH_CONF_TEST:="test"}
ISH_CONF_INIT=${ISH_CONF_INIT:="init"}
ISH_CONF_EXIT=${ISH_CONF_EXIT:="exit"}
ISH_CONF_TYPE=${ISH_CONF_TYPE:=".sh"}
[ "$ISH_CONF_PRE" = "" ] && declare -r ISH_CONF_PRE=ish
ish_conf() {
    [ "$#" -gt "1" ] && eval "ISH_CONF_$1=$2"
    echo $(eval "echo \$ISH_CONF_$1")
}
# }
## 2.个性化 # {
ISH_USER_EMAIL=${ISH_USER_EMAIL:="shylinuxc@gmail.com"}
ISH_USER_COLOR=${ISH_USER_COLOR:="true"}
ISH_USER_ERR_COUNT=0
ish_user() {
    whoami
}
ish_user_err_clear() {
    ISH_USER_ERR_COUNT=0
}
# }
## 3.可视化 # {
ISH_SHOW_COLOR_r="\e[31m"
ISH_SHOW_COLOR_g="\e[32m"
ISH_SHOW_COLOR_b="\e[34m"
ISH_SHOW_COLOR_end="\e[0m"
ish_show() {
    while [ "$#" -gt "0" ]; do case $1 in
        -username) echo -n "$(whoami)";;
        -hostname) echo -n "$(hostname)";;
        -date) echo -n "$(date +"%Y-%m-%d")";;
        -time) echo -n "$(date +"%Y-%m-%d %H:%M:%S")";;
        *)
            if local k=$1 && [ "${k:0:1}" = "-" ] ; then
                local color=$(eval "echo -ne \${ISH_SHOW_COLOR_${k:1}}" 2>/dev/null)
                [ "$ISH_USER_COLOR" = "true" ] && echo -ne "$color\b"
            else
                [ "$ISH_USER_COLOR" = "true" ] && echo -ne "$1$ISH_SHOW_COLOR_end"
            fi
            ;;
    esac; [ "$#" -gt "0" ] && shift && echo -n " "; done; echo
}
# }
## 4.结构化 # {
# $prefix
ish_list_parse='for _p in $(ish_get $prefix list); do #{
    local _name=${_p%%=*} && local _value=${_p#$_name} && _value=${_value#=}
    eval "local $_name=$(ish_get $prefix $_name)"
    [ "$1" != "" ] && eval "$_name=$1"
    [ \"$(eval "echo \$$_name")\" = "" ] || eval "$_name=$_value"
    eval "${prefix}_$_name=$_value"
    shift
done #}'

ish_list() {
    echo
}
# }

## 1.模块变量 # {
ISH_CTX_ORDER=${ISH_CTX_ORDER:=0}
ISH_CTX_MODULE=${ISH_CONF_PRE}_ctx
ISH_CTX_SCRIPT=${ISH_CTX_MODULE}
ISH_CTX_OBJECT=${ISH_CTX_MODULE}_obj_0
ish_ctx() {
    echo
}
# }
## 2.模块日志 # {
ISH_LOG_ERR=${ISH_CONF_ERR}
ISH_LOG_INFO=${ISH_CONF_LOG}
ish_log() {
    [ "$ISH_CONF_LEVEL" = "" ] && ish_show -time "$@" >$ISH_LOG_INFO && return
    for l in $(echo $ISH_CONF_LEVEL); do
        [ "$l" = "$1" ] && ish_show -time "$@" >$ISH_LOG_INFO 
    done
    return 0
}
ish_log_err() {
    let ISH_USER_ERR_COUNT=$ISH_USER_ERR_COUNT+1
    ish_show -time error -r "$@" >$ISH_LOG_ERR
}
ish_log_conf() { ish_log "conf" $@; }
ish_log_eval() { ish_log "eval" $@; }
ish_log_test() { ish_log "test" $@; }
ish_log_info() {
    local info="" && while [ "$#" -gt "0" ]; do
        info=$info"$1: $2 " && shift 2
    done
    ish_log info $info
}
ish_log_debug() { ish_log "debug" $@; }
ish_log_source() { ish_log "source" $@; }
ish_log_require() { ish_log "require" $@; }
# }
## 3.模块加载 # {
require_help() {
    echo -e "usage: $(_color green require \[as name\] file...)"
    echo -e "       source script $(_color underline file) as $(_color underline name)"
    echo
    echo -e "usage: $(_color yellow require \[as name\] mod file...)"
    echo -e "       auto download $(_color underline mod) (format like: github.com/shylinux/intshell) as $(_color underline name) and source script $(_color underline file)"
    echo
    echo -e "usage: $(_color red require \[as name\] mod)"
    echo -e "       auto download $(_color underline mod) as $(_color underline name) and source $(_color bold \${ISH_CONF_INIT}\${ISH_CONF_TYPE}) file"
    echo
}
require_path() {
    local name=$ISH_CONF_PATH/github.com/$1
    [ -d $name ] && echo $name && return
    local name=$ISH_CONF_ROOT/github.com/$1
    [ -d $name ] && echo $name && return
}
require_list() {
    # 加载脚本
    for p in $ISH_CONF_PATH $ISH_CONF_ROOT; do
        [ -d $p ] && for pp in $p/*; do
            [ -d $pp ] && for owner in $pp/*; do
                [ -d $owner ] && for repos in $owner/*; do
                    echo $repos
                done
            done
        done
        [ "$ISH_CONF_PATH" = "$ISH_CONF_ROOT" ] && break
    done
}
require() {
    # 解析参数
    [ -z "$1" ] && require_help && return
    local name=${ISH_CTX_MODULE#ish_} && [ "$1" = "as" ] && name=$2 && shift 2
    local mod=$1 file=$ISH_CONF_INIT$ISH_CONF_TYPE && shift && [ -z "$1" ] || file="$@"
    ish_log_require as $name $(_color g $mod) $file

    # 下载脚本
    local p="${mod%%/*}" && p=${p%:} && case "$p" in
        ${ISH_CONF_FTP}) local pp=$(_name $mod); [ -f "$ISH_CONF_ROOT/$pp/$file" ] || [ -f "$ISH_CONF_PATH/$pp/$file" ] || if true; then
                    mkdir -p $ISH_CONF_PATH/$pp && wget $mod/$file -O "$ISH_CONF_PATH/$pp/$file"
                fi; mod=$pp;;
        $ISH_CONF_HUB) [ -d "$ISH_CONF_ROOT/$mod/.git" ] || [ -d "$ISH_CONF_PATH/$mod/.git" ] || if true; then
                    ish_log_debug -g "clone https://$mod => $ISH_CONF_PATH/$mod"
                    git clone ${ISH_CONF_HUB_PROXY}$mod $ISH_CONF_PATH/$mod
                fi;;
    esac

    # 加载脚本
    for p in $ISH_CONF_PATH $ISH_CONF_ROOT; do
        if [ -e "${p%/*}/$mod" ]; then
            __load "$name" ${p%/*}/$mod
            return
        fi
        if [ -e "$p/$mod" ]; then 
            __load "$name" $p/$mod
            return
        fi
        if [ -e "$mod" ]; then
            __load "$name" $mod
            return
        fi
        [ -d "$p/$mod" ] && for i in $file; do
            __load "${name}" "$p/$mod/$i"
        done && return
    done

    ish_log_require "$ctx_dev/intshell/$mod"
    local ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/$mod >$ctx_temp && __load $name $ctx_temp && return
    ish_log_err "not found $p/$mod"
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
    [ "$ISH_USER_COLOR" != "true" ] && shift && echo "$*" && return
    local prefix="" && for c in $(echo $1); do
        prefix=$prefix$(_eval "echo \"\$ISH_SHOW_COLOR_${c}\"")
    done && shift
    echo "$prefix$*$ISH_SHOW_COLOR_end"
}
_eval() {
    ish_log_eval "$*" && eval "$*"
}
_conf() {
    ish_log_conf "$*" && case "$1" in
        get) _eval "[ -z \"\$${2}_$3\" ] && ${2}_$3=\"$4\"; echo \$${2}_$3";;
        set) [ "$4" = "" ] && _eval "${2}_${3}=\"$5\"" || _eval "${2}_${3}=\"$4\"" ;;
        def) _eval "[ \"\$${2}_${3}\" = \"\" ] && ${2}_${3}=$4";;
        run) local func=$2 && shift 2 && declare -f $func >/dev/null && $func "$@";;
    esac
}
_load() {
    local pre=$1 && shift
    ish_log_source "$pre "$@"-> $ISH_CTX_SCRIPT"
    source ./${pre##*/} "$@" >/dev/null
}
__load() {
    local name=$1 && shift 1 && local back=$PWD pre=$1 && [ -f "$pre" ] || return
    [ -d "${pre%/*}" ] && cd ${pre%/*}
    [ "$ISH_CTX_FILE" = "$1" ] && return
    ISH_CTX_FILE=$1 ISH_CTX_MODULE=$(_name ish_${name}) ISH_CTX_SCRIPT=$(_name ish_${name}) _load "$@"
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
_help() { _plug $ISH_CONF_HELP; }
_test() { _plug $ISH_CONF_TEST; }
_init() { _plug $ISH_CONF_INIT; }
_exit() { _plug $ISH_CONF_EXIT; }
trap _exit EXIT
# _init;
# }
## 4.模块接口 # {
ish_help() {
    if [ "$1" = "" ]; then
        echo -e "usage: $(_color green ish mod/file_fun arg...)"
        echo -e "       auto download $(_color underline mod) and auto load $(_color underline file) and then call the $(_color underline fun)"
        echo -e "       demo: ish github.com/shylinux/shell/base.cli.os_os_system"
        echo
        echo -e "usage: $(_color cyan ish mod key arg...)"
        echo -e "       get module of $(_color underline key)"
        echo
        echo -e "usage: $(_color cyan ish run fun arg...)"
        echo -e "       call function $(_color underline fun) in the script $(_color bold \${ISH_CTX_SCRIPT})"
        echo
        echo -e "usage: $(_color blue ish get key \[value\])"
        echo -e "       get value of variable $(_color underline key) in the script $(_color bold \${ISH_CTX_SCRIPT}) or default $(_color underline value)"
        echo
        echo -e "usage: $(_color purple ish set key value)"
        echo -e "       set $(_color underline value) of variable $(_color underline key) in the script $(_color bold \${ISH_CTX_SCRIPT})"
        echo
        echo -e "usage: $(_color red ish def key value)"
        echo -e "       set default $(_color underline value) of variable $(_color underline key) in the script $(_color bold \${ISH_CTX_SCRIPT})"
    fi
}
ish() {
    [ "$1" = "" ] && ish_help && return
    case "$1" in get|set|def) ish_ctx_script "$@"; return;; esac
    case "$1" in run) shift && ish_ctx_script "$@"; return;; esac
    case "$1" in mod) shift && _meta "$@"; return;; esac

    local fun=${ISH_CTX_SCRIPT}_$(_name $1)
    declare -f $fun >/dev/null && shift && $fun $@ && return

    local mod=$1 && shift && local file=${mod##*/} && mod=${mod%/$file}
    [ "$mod" = "$file" ] && mod=""
    local fun=${file#*_} && [ "$fun" = "$file" ] && fun="" || file=${file%_$fun}
    file=${file//./\/}
    [ "$mod" != "" ] && ISH_CTX_MODULE=$(_name ish_$mod) ISH_CTX_SCRIPT=$(_name ish_$mod) ish_ctx_script run "${mod}" "${file}" "${fun}" $@ || ish_ctx_script run "${mod}" "${file}" "${fun}" $@
}
ish_get() {
    local name=$1 value="" && shift && while [ "$name" != "" ]; do
        value=$(eval "echo \$${name}_$1") && [ "$value" != "" ] && break
        name=${name%_*}
        [ "$name" = "$ISH_CONF_PRE" ] && break
    done
    echo $value
}
ish_def() {
    local prefix=$1 && shift
    while [ "$#" -gt "0" ]; do
        local name=${prefix}_$1 && shift && local value=$(eval "echo \$${name}")
        [ "$value" = "" ] && eval "${name}=$1"
        eval "echo \$${name}"
        shift
    done
}
ish_arg() {
    local prefix=$1 list=$2 && shift
    for _l in $list; do
        local value=$(ish_get $prefix $name)


    done

    name=$2 && shift 2
    [ "$1" != "" ] && value=$1
}
# }

