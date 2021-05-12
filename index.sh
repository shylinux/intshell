#!/bin/sh

export ctx_dev=${ctx_dev:="https://shylinux.com"}

down_file() { # 下载文件 dir url
    curl --create-dirs -o $1 -fsSL $ctx_dev/$2
}
temp_file() { # 加载文件 url arg...
    ctx_temp=$(mktemp) && down_file $ctx_temp $1 && shift && source $ctx_temp "$@"
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
    down_file bin/ice.bin publish/$bin && chmod u+x bin/ice.bin
    down_file bin/ice.sh publish/ice.sh && chmod u+x bin/ice.sh
}
prepare_tmux() {
    down_file etc/tmux.conf intshell/misc/tmux/tmux.conf
    down_file bin/tmux.sh intshell/misc/tmux/local.sh
}
prepare_script() {
    for script in "$@"; do temp_file intshell/$script; done 
}

main() {
    case "$1" in
        source) # 源码安装
            git clone https://github.com/shylinux/contexts
            cd contexts && source etc/miss.sh
            ;;
        binary) # 应用安装
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice
            bin/ice.sh serve serve start dev dev "$@"
            ;;
        dev) # 开发环境
            prepare_script plug.sh conf.sh miss.sh
            case "$(uname)" in
                Darwin) xcode-select --install 2>/dev/null ;;
                Linux) yum install -y wget tmux make git vim ;;
            esac

            git config --gloal url."$ctx_dev/code/git/repos".insteadOf "https://github.com/shylinux"
            down_file go.mod publish/go.mod && down_file etc/miss.sh publish/miss.sh && source etc/miss.sh
            ;;
        app) # 生产环境
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice && bin/ice.sh serve serve start dev dev "$@"
            ;;
        *) # 终端环境
            prepare_script plug.sh conf.sh
            temp_file publish/order.sh "$@"
            ;;
    esac
}

main "$@"
