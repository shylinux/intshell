#!/bin/sh

temp_source() {
    for script in "$@"; do
        ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/$script >$ctx_temp; source $ctx_temp
    done 
}

ctx_dev=${ctx_dev:="https://shylinux.com"}; case "$1" in
    dev) # 开发环境
        temp_source plug.sh conf.sh miss.sh
        case "$(uname)" in
            Darwin)
                xcode-select --install
                ;;
            Linux)
                curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo && yum -y update
                yum install -y wget make tmux git vim
                ;;
            *)
                ;;
        esac

        [ -d contexts ] || git clone https://github.com/shylinux/contexts
        cd contexts && ish_miss_prepare_develop && source etc/miss.sh
        ;;
    ice) # 生产环境
        mkdir bin &>/dev/null; curl -sL $ctx_dev/publish/ice.sh -o bin/ice.sh && chmod u+x bin/ice.sh && bin/ice.sh serve serve start dev dev
        ;;
    *) # 终端环境
        temp_source plug.sh conf.sh
esac
