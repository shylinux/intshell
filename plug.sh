# intshell: 终端 神农架 整个脚本
# PMS: a plugin manger system
#
# 1.PLUG
# $ git clone https://github.com/shylinux/intshell ~/.ish
# $ source ~/.ish/plug.sh

## 1.配置 # {
ISH_CONF_PRE=ish
ISH_CONF_LOG=${ISH_CONF_LOG:="/dev/stderr"}
ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="require request source alias debug"}
ISH_CONF_COLOR=${ISH_CONF_COLOR:="true"}

ISH_CONF_PATH=${ISH_CONF_PATH:=$PWD/.ish/pluged}
ISH_CONF_ROOT=${ISH_CONF_ROOT:="$HOME/.ish/pluged"}
ISH_CONF_HUB_PROXY=${ISH_CONF_HUB_PROXY:="https://"}
ISH_CONF_DEV=${ISH_CONF_DEV:="http://localhost:9020"}
# }
## 2.日志 # {
ISH_SHOW_COLOR_r="\e[31m"
ISH_SHOW_COLOR_g="\e[32m"
ISH_SHOW_COLOR_b="\e[34m"
ISH_SHOW_COLOR_end="\e[0m"
ish_show() {
    local space=" " count=0; while [ "$#" -gt "0" ]; do space=" "; case $1 in
        -username) echo -n "$(whoami)";;
        -hostname) echo -n "$(hostname)";;
        -date) echo -n "$(date +"%Y-%m-%d")";;
        -time) echo -n "$(date +"%Y-%m-%d %H:%M:%S")";;
        *) if local k=$1 && [ "${k:0:1}" = "-" ] ; then space=""
            local color=$(eval "printf \${ISH_SHOW_COLOR_${k:1}}" 2>/dev/null)
            [ "$ISH_CONF_COLOR" = "true" ] && printf "$color" && ((count++))
        else
            printf "$1"; [ $count -gt 0 ] && printf "$ISH_SHOW_COLOR_end" && ((count--))
        fi;;
    esac; [ "$#" -gt "0" ] && shift && echo -n "$space"; done; echo
}
ish_log() {
    for l in $(echo ${ISH_CONF_LEVEL:=$1}); do
        [ "$l" = "$1" ] && ish_show -time "$@" >$ISH_CONF_LOG 
    done; return 0
}
ish_log_alias() { ish_log "alias" "$@"; }
ish_log_source() { ish_log "source" "$@"; }
ish_log_request() { ish_log "request" "$@"; }
ish_log_require() { ish_log "require" "$@"; }
ish_log_debug() { ish_log "debug" "$@" `_fileline 2`; }
# }
## 2.加载 # {
require_path() { # 目录
    for name in "$@"; do
        [ -e $name ] && echo $name && continue
        for p in $ISH_CONF_PATH $ISH_CONF_ROOT; do
            [ -e $p/$name ] && echo $p/$name && break
            [ -e ${p%/*}/$name ] && echo ${p%/*}/$name && break
        done
    done
}
require_fork() {  # 仓库
    local name=$1 mod=$1 tag=$2 && shift 2; [ "$tag" = "" ] || name=$mod@$tag
    local p=$(require_path $name); [ "$p" != "" ] && echo $p && return
    echo "$mod"| grep "^git" &>/dev/null || return

    ish_log_debug -g "clone ${ISH_CONF_HUB_PROXY}$mod => $ISH_CONF_PATH/$name"
    git clone ${ISH_CONF_HUB_PROXY}$mod $ISH_CONF_PATH/$name &>/dev/null
    echo $ISH_CONF_PATH/$name; [ "$tag" = "" ] && return

    cd "$ISH_CONF_PATH/$name"; git checkout $tag &>/dev/null && rm -rf .git; cd - &>/dev/null
}
require_pull() { # 更新
    local back=$PWD; cd "$(require_fork $1)" && ish_log_debug pwd $PWD && git pull; cd $back; echo
}
require_temp() { # 下载
    for name in "$@"; do local temp=$(mktemp) 
        ish_log_request "$temp <= $ctx_dev/intshell/$name"
        curl --create-dirs -fsSL -o $temp $ctx_dev/intshell/$name && echo $temp
    done
}
require() { # require [ as name ] [mod] file arg...
    local name=${ISH_CTX_MODULE#ish_} && [ "$1" = "as" ] && name=$2 && shift 2
    local mod=$1 tag= && shift; mod=${mod#https://}
    tag=${mod#*@} mod=${mod%@*}; [ "$tag" = "$mod" ] && tag=""
    ish_log_require $name -g $mod by `_fileline 2`

    local file=$(require_path $mod)
    [ -f "$file" ] || if echo $mod| grep "^git" &>/dev/null; then
        file=$(require_fork "$mod" "$tag")/$1 && shift
    else
        file=$(require_temp $mod)
    fi;

    [ -f "$file" ] || return 0
    local back=$PWD && [ -d "${file%/*}" ] && cd ${file%/*}
    ISH_CTX_MODULE=$(_name ish_${name}) ISH_CTX_SCRIPT=$1 _load $file "$@"
    cd $back; return 0
}
_load() {
    local file=$1 && shift
    ish_log_source "$file "$@""
    source ./${file##*/} "$@"
}
_name() {
    local name="$*" && echo ${name//[^a-zA-Z0-9_]/_}
}
_fileline() {
    local index=$((${1}-1))
    echo "${BASH_SOURCE[$1]}:${BASH_LINENO[$index]}:${FUNCNAME[$1]}"
}

