#!/bin/sh

ish_help_show() {
    local key="" tab="" index=0 value=""
    while [ "$#" -gt "0" ] ; do
        key="$1" && shift && value=$1
        case $key in
        end) return;;
        title)
            local k=$1 && [ "${k:0:1}" = "-" ] && shift && local color=$(eval "echo \${ISH_SHOW_COLOR_${k:1}}" 2>/dev/null)
            [ "$ISH_USER_COLOR" = "true" ] && echo -e "$color$1$ISH_SHOW_COLOR_end" || echo "$1" 
            ;;
        usage)
            local k=$1 && [ "${k:0:1}" = "-" ] && shift && local color=$(eval "echo \${ISH_SHOW_COLOR_${k:1}}" 2>/dev/null)
            [ "$ISH_USER_COLOR" = "true" ] && echo -e "$key: $color$1$ISH_SHOW_COLOR_end" || echo "$key: $1" 
            ;;
        index) echo "$((index++)): $value" ;;
        "") echo "$tab  $value";;
        *) echo "$key: $value";;
        esac
        [ "$#" -gt "0" ] && shift && [ "$key" != "" ] && tab=${key//[^\ ]/\ }
    done
    return 0
}

ish_help_repos="github.com/shylinux/intshell"
ish_help_owner="shylinuxc@gmail.com"
ish_help_product="plugin manager"
ish_help_version="v0.0.1"
ish_help_repos() {
    ish_help_show \
        repos "$ish_help_repos" \
        owner "$ish_help_owner" \
        product "$ish_help_product" \
        version "$ish_help_version"
}
ish_help_script() { 
    ish_help_show \
        XXX_help "文档化" XXX_test "标准化" \
        XXX_init "初始化" XXX_exit "序列化" \
        XXX_conf "配置化" XXX_auto "自动化" \
        XXX_make "场景化" XXX_user "个性化" \
        XXX_info "信息化" XXX_list "结构化" \
        XXX_show "可视化" XXX_view "结构化" \
        XXX_ctx "变量" XXX_log "日志"
}
ish_help_require() { require_help $@; }
ish_help_ish() { ish_help; }
ish_help_list() { 
    ish_help_show \
        index repos \
        index script \
        index require \
        index ish
}

