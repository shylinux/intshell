# intshell: 终端 神农架 整个脚本
# PMS: a plugin manger system
#
# 1.PLUG
# $ git clone https://github.com/shylinux/intshell ~/.ish
# $ source ~/.ish/plug.sh
# $ require_help
#
## 1.场景化 # {
ISH_CONF_ERR=${ISH_CONF_ERR:="/dev/stderr"}
ISH_CONF_LOG=${ISH_CONF_LOG:="/dev/stderr"}
ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="require request source alias debug test"}

ISH_CONF_TASK=${ISH_CONF_TASK:=$PWD}
ISH_CONF_WORK=${ISH_CONF_WORK:=$PWD/usr/local/work}
ISH_CONF_MISS=${ISH_CONF_MISS:="etc/miss.sh"}

ISH_CONF_PATH=${ISH_CONF_PATH:=$PWD/.ish/pluged}
ISH_CONF_ROOT=${ISH_CONF_ROOT:="$HOME/.ish/pluged"}
ISH_CONF_HUB_PROXY=${ISH_CONF_HUB_PROXY:="https://"}

[ "$ISH_CONF_PRE" = "" ] && declare -r ISH_CONF_PRE=ish
ish_conf() {
    if [ "$#" -eq "0" ] ; then
        declare |grep "^ISH_CONF"
        return
    fi

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
    local space=" "
    while [ "$#" -gt "0" ]; do space=" "; case $1 in
        -username) echo -n "$(whoami)";;
        -hostname) echo -n "$(hostname)";;
        -date) echo -n "$(date +"%Y-%m-%d")";;
        -time) echo -n "$(date +"%Y-%m-%d %H:%M:%S")";;
        *)
            if local k=$1 && [ "${k:0:1}" = "-" ] ; then
                local color=$(eval "echo -ne \${ISH_SHOW_COLOR_${k:1}}" 2>/dev/null)
                [ "$ISH_USER_COLOR" = "true" ] && echo -ne "$color"
                space=""
            else
                echo -ne "$1"
                [ "$ISH_USER_COLOR" = "true" ] && echo -ne "$ISH_SHOW_COLOR_end"
            fi
            ;;
    esac; [ "$#" -gt "0" ] && shift && echo -n "$space"; done; echo
}
# }

## 1.模块日志 # {
ISH_LOG_ERR=${ISH_CONF_ERR}
ISH_LOG_INFO=${ISH_CONF_LOG}
ish_log() {
    [ "$ISH_CONF_LEVEL" = "" ] && ish_show -time "$@" >$ISH_LOG_INFO && return 0
    for l in $(echo $ISH_CONF_LEVEL); do
        [ "$l" = "$1" ] && ish_show -time "$@" >$ISH_LOG_INFO 
    done; return 0
}
ish_log_err() {
    let ISH_USER_ERR_COUNT=$ISH_USER_ERR_COUNT+1
    ish_show -time error -r "$*" >$ISH_LOG_ERR
}
ish_log_info() {
    local info="" && while [ "$#" -gt "0" ]; do
        info=$info"$1: $2 " && shift 2
    done
    ish_log info $info
}
ish_log_test() { ish_log "test" $@; }
ish_log_debug() { ish_log "debug" "$@"; }
ish_log_alias() { ish_log "alias" "$@"; }
ish_log_source() { ish_log "source" "$@"; }
ish_log_request() { ish_log "request" "$@"; }
ish_log_require() { ish_log "require" "$@"; }
# }
## 2.模块加载 # {
require_help() {
    echo -e "usage: $(_color green require \[as name\] file)"
    echo -e "       source script $(_color underline file) as $(_color underline name)"
    echo
    echo -e "usage: $(_color yellow require \[as name\] mod file...)"
    echo -e "       auto download $(_color underline mod) (format like: github.com/shylinux/intshell@v0.0.1) then source script $(_color underline file) as $(_color underline name)"
    echo
}
require_path() {
    for name in "$@"; do
        [ -e $name ] && echo $name && continue
        for p in $ISH_CONF_PATH $ISH_CONF_ROOT; do
            [ -e $p/$name ] && echo $p/$name && break
            [ -e ${p%/*}/$name ] && echo ${p%/*}/$name && break
        done
    done
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
require_fork() {
    local name=$1 mod=$1 tag=$2 && shift 2; [ "$tag" = "" ] || name=$mod@$tag
    case ${mod%%/*} in
        github.com|git.zuoyebang.cc)
            for p in $ISH_CONF_PATH $ISH_CONF_ROOT; do
                if [ -d "$p/$name" ]; then
                    for file in "$@"; do
                        echo $p/$name/$file
                    done
                    return
                fi
            done

            ish_log_debug -g "clone ${ISH_CONF_HUB_PROXY}$mod => $ISH_CONF_PATH/$name"
            git clone ${ISH_CONF_HUB_PROXY}$mod $ISH_CONF_PATH/$name >/dev/null

            if [ "$tag" != "" ]; then
                cd $ISH_CONF_PATH/$name; git checkout $tag; rm -rf .git; cd -
            fi >/dev/null

            for file in "$@"; do
                echo $ISH_CONF_PATH/$name/$file
            done
    esac
}
require_temp() {
    for name in "$@"; do
        local temp=$(mktemp) && curl -sL $ctx_dev/intshell/$name >$temp && echo $temp
        ish_log_request "$ctx_dev/intshell/$name => $temp"
    done
}
require() { # require [ as name ] [mod] file arg...
    # 解析参数
    [ -z "$1" ] && require_help && return
    local name=${ISH_CTX_MODULE#ish_} && [ "$1" = "as" ] && name=$2 && shift 2
    local mod=$1 tag= && shift; mod=${mod#https://}
    ish_log_require as $name -g $mod

    # 本地脚本
    local file=$(require_path $mod)
    [ -e "$file" ] && __load "$name" $file && return

    # 项目脚本
    tag=${mod#*@} mod=${mod%@*}; [ "$tag" = "$mod" ] && tag=""
    local file=$(require_fork "$mod" "$tag" "$@")
    [ -e "$file" ] && __load "$name" $file && return

    # 远程脚本
    local file=$(require_temp $mod)
    [ -e "$file" ] && __load "$name" $file && return

    # 查找失败
    ish_log_err "not found $mod"
}

__load() {
    local name=$1 && shift 1 && local back=$PWD pre=$1 && [ -f "$pre" ] || return 0
    [ -d "${pre%/*}" ] && cd ${pre%/*}
    [ "$ISH_CTX_FILE" = "$1" ] && return 0
    ISH_CTX_FILE=$1 ISH_CTX_MODULE=$(_name ish_${name}) ISH_CTX_SCRIPT=$(_name ish_${name}) _load "$@"
    cd $back
    return 0
}
_load() {
    local pre=$1 && shift
    # ish_log_source "$pre "$@"-> $ISH_CTX_SCRIPT"
    ish_log_source "$pre "$@""
    source ./${pre##*/} "$@" >/dev/null
}
_name() {
    local name="$*" && echo ${name//[^a-zA-Z0-9_]/_}
}
_eval() {
    eval "$*"
}
_color() {
    [ "$ISH_USER_COLOR" != "true" ] && shift && echo "$*" && return
    local prefix="" && for c in $(echo $1); do
        prefix=$prefix$(_eval "echo \"\$ISH_SHOW_COLOR_${c}\"")
    done && shift
    echo "$prefix$*$ISH_SHOW_COLOR_end"
}

