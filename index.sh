#!/bin/sh

temp_source() {
    for script in "$@"; do
        ctx_temp=$(mktemp); curl -fsSL $ctx_dev/intshell/$script -o $ctx_temp; source $ctx_temp
    done 
}
down_source() {
    [ -f "$1" ] || curl -fsSL $ctx_dev/$2 --create-dirs -o $1
}
prepare_tmux() {
    down_source etc/tmux.conf intshell/misc/tmux/tmux.conf
    down_source bin/tmux.sh intshell/misc/tmux/local.sh
}

ctx_dev=${ctx_dev:="https://shylinux.com"}; case "$1" in
    dev) # 开发环境
        temp_source plug.sh conf.sh miss.sh
        case "$(uname)" in
            Darwin)
                xcode-select --install 2>/dev/null
                # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                ;;
            Linux)
                ish_log_request "mirrors.aliyun.com"
                # curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && yum -y update
                yum install -y wget make tmux git vim
                ;;
            *)
                ;;
        esac

        [ -d contexts ] || git clone --depth 1 https://gitee.com/shylinuxc/contexts $PWD/contexts
        ISH_CONF_HUB_PROXY=$ctx_dev/code/git/ && cd contexts && source etc/miss.sh
        ;;
    ice) # 生产环境
        prepare_tmux
        export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}; shift
        down_source bin/ice.sh publish/ice.sh && chmod u+x bin/ice.sh && bin/ice.sh serve serve start dev dev "$@"
        ;;
    *) # 终端环境
        temp_source plug.sh conf.sh
esac
