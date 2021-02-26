#!/bin/sh

temp_intshell() {
    for script in "$@"; do
        ctx_temp=$(mktemp); curl -fsSL $ctx_dev/intshell/$script -o $ctx_temp; source $ctx_temp
    done 
}
temp_source() { # path...
    for script in "$@"; do
        ctx_temp=$(mktemp); curl -fsSL $ctx_dev/$script -o $ctx_temp; source $ctx_temp
    done 
}
down_source() { # path url
    [ -f "$1" ] || curl -fsSL $ctx_dev/$2 --create-dirs -o $1
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
    down_source bin/ice.bin publish/$bin && chmod u+x bin/ice.bin
    down_source bin/ice.sh publish/ice.sh && chmod u+x bin/ice.sh
}
prepare_tmux() {
    down_source etc/tmux.conf intshell/misc/tmux/tmux.conf
    down_source bin/tmux.sh intshell/misc/tmux/local.sh
}
prepare_main() {
    ctx_dev=${ctx_dev:="https://shylinux.com"}; case "$1" in
        dev) # 开发环境
            temp_intshell plug.sh conf.sh miss.sh
            case "$(uname)" in
                Darwin)
                    xcode-select --install 2>/dev/null
                    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    ;;
                Linux)
                    # ish_log_request "mirrors.aliyun.com"
                    # curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo && yum -y update
                    yum install -y wget tmux make git vim
                    ;;
            esac

            export ISH_CONF_HUB_PROXY=$ctx_dev/code/git/
            down_source go.mod publish/go.mod && down_source etc/miss.sh publish/miss.sh && source etc/miss.sh
            ;;
        ice) # 生产环境
            prepare_tmux
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}; shift
            prepare_ice && bin/ice.sh serve serve start dev dev "$@"
            ;;
        *) # 终端环境
            # ISH_CONF_LEVEL="debug"
            temp_intshell plug.sh conf.sh
            temp_source publish/order.sh
    esac
}
prepare_main "$@"
