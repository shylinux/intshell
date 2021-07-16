#!/bin/sh

export ctx_dev=${ctx_dev:="https://shylinux.com"}

_down_file() { # 下载文件 dir url
    curl --create-dirs -o $1 -fsSL $ctx_dev/$2
}
_temp_file() { # 加载文件 url arg...
    ctx_temp=$(mktemp) && _down_file $ctx_temp $1 && shift && source $ctx_temp "$@"
}

prepare_system() {
    case "$(uname)" in
        Darwin) xcode-select --install 2>/dev/null ;;
        Linux) yum install -y make git vim tmux ;;
    esac
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
    case "$1" in
        module) # 创建模块
            prepare_system; prepare_script plug.sh conf.sh miss.sh
            ish_miss_prepare_compile
            ish_miss_prepare_develop
            ish_miss_prepare_install

            ish_miss_prepare_contexts
            ish_miss_prepare_volcanos

            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            make && ish_miss_serve dev dev
            ;;
        source) # 源码安装
            prepare_system
            git clone https://github.com/shylinux/contexts
            cd contexts && source etc/miss.sh
            ;;
        binary) # 应用安装
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice && bin/ice.sh serve serve start dev dev "$@"
            ;;
        dev) # 开发环境
            prepare_system; prepare_script plug.sh conf.sh miss.sh

            # git config --global url."$ctx_dev/code/git/repos".insteadOf "https://github.com/shylinux"
            git config --global url."https://shylinux.com/code/git/repos".insteadOf "https://github.com/shylinux"
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
