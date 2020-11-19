#!/bin/sh

temp_source() {
    for script in "$@"; do
        ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/$script >$ctx_temp; source $ctx_temp
    done 
}

ctx_dev=${ctx_dev:="https://shylinux.com"}; case "$1" in
    dev)
        temp_source plug.sh conf.sh miss.sh

        curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo && yum -y update
        yum install -y wget make tmux git vim

        ish_miss_prepare_develop
        export PATH=$PWD/usr/local/go/bin:$PATH

        git clone https://github.com/shylinux/contexts && cd contexts && source etc/miss.sh
        ;;
    ice)
        mkdir bin &>/dev/null; curl -sL $ctx_dev/publish/ice.sh -o bin/ice.sh && chmod u+x bin/ice.sh && bin/ice.sh serve serve start dev dev
        ;;
    *)
        temp_source plug.sh conf.sh miss.sh
esac
