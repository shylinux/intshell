#!/bin/sh

export ctx_dev=${ctx_dev:="https://shylinux.com"}

_down_file() { # 下载文件 dir url
    curl --create-dirs -o $1 -fsSL $ctx_dev/$2
}
_temp_file() { # 加载文件 url arg...
    ctx_temp=$(mktemp) && _down_file $ctx_temp $1 && shift && source $ctx_temp "$@"
}
_down_tar() { # 下载文件 dir url
    [ -f $1 ] && return
    echo "download $ctx_dev/$2"
    curl --create-dirs -o $1 -fSL $ctx_dev/$2 && tar -xvf $1
}

prepare_system() {
    case "$(uname)" in
        Darwin) xcode-select --install 2>/dev/null ;;
        Linux) yum install -y make git vim tmux ;;
    esac
}
prepare_package() {
    prepare_system; local back=$PWD; cd ~/
    _down_tar go.tar.gz publish/go.tar.gz
    _down_tar vim.tar.gz publish/vim.tar.gz
    _down_tar ish.tar.gz publish/ish.tar.gz
    _down_tar local.bin.tar.gz publish/local.bin.tar.gz
    cd $back
}
prepare_script() {
    for script in "$@"; do _temp_file intshell/$script; done 
}
prepare_tmux() {
    _down_file etc/tmux.conf intshell/dev/tmux/tmux.conf
    _down_file bin/tmux.sh intshell/dev/tmux/local.sh
}
prepare_ice() {
    bin="ice"
    case `uname -s` in
        Darwin) bin=${bin}.darwin ;;
        Linux) bin=${bin}.linux ;;
        *) bin=${bin}.windows ;;
    esac
    case `uname -m` in
        x86_64) bin=${bin}.amd64 ;;
        arm*) bin=${bin}.arm ;;
        *) bin=${bin}.386 ;;
    esac
    _down_file bin/ice.bin publish/$bin && chmod u+x bin/ice.bin
    _down_file bin/ice.sh publish/ice.sh && chmod u+x bin/ice.sh
}

main() {
    ISH_CONF_LEVEL="require request source debug"
    case "$1" in
        project) # 创建项目
            prepare_system; prepare_script plug.sh conf.sh miss.sh
            ish_miss_prepare_compile
            ish_miss_prepare_develop
            ish_miss_prepare_install

            ish_miss_prepare_contexts

            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            make && ish_miss_serve
            ;;
        source) # 源码安装
            prepare_system
            git clone https://shylinux.com/x/contexts
            cd contexts && source etc/miss.sh
            ;;
        binary) # 应用安装
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice && bin/ice.sh serve serve start "$@"
            ;;
        dev) # 开发环境
            prepare_package; prepare_script plug.sh conf.sh miss.sh; ish_sys_dev_config
            _down_file go.mod publish/go.mod && _down_file etc/miss.sh publish/miss.sh && source etc/miss.sh
            ;;
        app) # 生产环境
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice && bin/ice.sh serve serve start dev dev "$@"
            ;;
        *) # 终端环境
            prepare_script plug.sh conf.sh
            _temp_file publish/order.sh "$@"
            ;;
    esac
}

main "$@"
