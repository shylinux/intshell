#!/bin/sh

## 1.配置 # {
ISH_CONF_HOME=${ISH_CONF_HOME:="$HOME/.ish/pluged"}
ISH_CONF_PATH=${ISH_CONF_PATH:="$PWD/.ish/pluged"}
ISH_CONF_LOG=${ISH_CONF_LOG:="/dev/stderr"}
ISH_CONF_LEVEL=${ISH_CONF_LEVEL:="notice debug"}
ISH_CONF_COLOR=${ISH_CONF_COLOR:="true"}
# }
## 2.日志 # {
ISH_SHOW_COLOR_r="\e[31m"
ISH_SHOW_COLOR_g="\e[32m"
ISH_SHOW_COLOR_b="\e[34m"
ISH_SHOW_COLOR_end="\e[0m"
ish_show() {
    local space=" " count=""; while [ "$#" -gt "0" ]; do space=" "; case $1 in
        -username) printf "$(whoami)";;
        -hostname) printf "$(hostname)";;
        -date) printf "$(date +"%Y-%m-%d")";;
        -time) printf "$(date +"%Y-%m-%d %H:%M:%S")";;
        *) if local k=$1 && [ "${k:0:1}" = "-" ] ; then space=""
            local color=$(eval "printf \${ISH_SHOW_COLOR_${k:1}}" 2>/dev/null)
            [ "$ISH_CONF_COLOR" = "true" ] && printf "$color" && count="need"
        else
            printf "$1"; [ -n $count ] && printf "$ISH_SHOW_COLOR_end" && count=
        fi;;
    esac; [ "$#" -gt "0" ] && shift && printf "$space"; done; echo
}
ish_log() {
    for l in $(echo ${ISH_CONF_LEVEL:=$1}); do [ "$l" = "$1" ] && ish_show -time "$@" >$ISH_CONF_LOG; done; return 0
}
ish_log_require() { ish_log "require" "$@"; }
ish_log_request() { ish_log "request" "$@"; }
ish_log_notice() { ish_log "notice" "$@"; }
ish_log_alias() { ish_log "alias" "$@"; }
ish_log_debug() { ish_log "debug" "$@"; }
# }
## 3.模块 # {
require_path() {
    for name in "$@"; do [ -e $name ] && echo $name && continue
        for p in $PWD/.ish/pluged $ISH_CONF_PATH $ISH_CONF_HOME; do
            [ -e $p/$name ] && echo $p/$name && break
            [ -e ${p%/*}/$name ] && echo ${p%/*}/$name && break
        done
    done
}
require_fork() {
	local repos=$1 && shift; local p=$(require_path $repos); [ "$p" != "" ] && echo $p && return
	ish_log_notice -g "clone $ISH_CONF_PATH/$repos"; git clone https://$repos $ISH_CONF_PATH/$repos &>/dev/null && echo $ISH_CONF_PATH/$repos
}
require_pull() {
    local back=$PWD; cd "$(require_fork $1)" && ish_log_notice repos $PWD && git pull; cd $back; echo
}
require_temp() {
	for file in "$@"; do
		local temp=$(mktemp); if curl -h &>/dev/null; then curl -o $temp -fsSL $file; else wget -O $temp -q $file; fi && echo $temp
	done 2>/dev/null 
}
require() {
    local mod=$1 && shift; local file=$(require_path $mod) host=$ctx_dev
    [ -f "$file" ] || if echo $mod| grep ".git$" &>/dev/null; then
        file=$(require_fork "$mod")/$1 && shift
    elif echo $mod| grep "^git" &>/dev/null; then
        file=$(require_fork "$mod")/$1 && shift
	elif echo $mod| grep "^http" &>/dev/null; then
        file=$(require_temp "$mod")
    elif echo $mod| grep "^/" &>/dev/null; then
        file=$(require_temp "$ctx_dev$mod")
    elif echo $mod| grep "^src/" &>/dev/null; then
        file=$(require_temp "$ctx_dev/require/$mod?pod=$ctx_pod")
		host=$host/require
    else
        [ -z "$file" ] && file=$(require_temp $ctx_dev/$mod)
		[ -z "$file" ] && file=$(require_temp "$ctx_dev/require/$mod?pod=$ctx_pod")
		[ -z "$file" ] && file=$(require_temp "$ctx_dev/require/${ISH_CTX_MODULE%/*}/$mod?pod=$ctx_pod")
		host=$host/require
    fi; [ -f "$file" ] || return 0;
	if echo "$file"| grep "/tmp." &>/dev/null; then ish_log_require "$file <= $host/$mod"; else ish_log_require "$file"; fi
   	eval "url=$(echo "$mod"|grep -o "?.*"|tr "?&" "   ")"
    ISH_CTX_MODULE=$mod ISH_CTX_SCRIPT=$file source $file "$@"
}
request() {
	local url="$ctx_dev/chat/cmd/$1" sep="?" arg=; shift
   	for arg in "$@"; do arg=$(ish_sys_web_word "$arg")
		if echo $arg|grep "=" &>/dev/null; then url=$url${sep}$arg; else url=$url${sep}arg=$arg; fi; sep="&"
	done; local temp=$(mktemp); ish_log_request "$temp <= $url"
   	if curl -h &>/dev/null; then curl -o $temp -fsSL $url; else wget -O $temp -q $url; fi && cat $temp
}
