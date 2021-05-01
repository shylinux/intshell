#!/bin/sh

temp_intshell() { # 加载脚本 file...
    for script in "$@"; do temp_source intshell/$script; done 
}
temp_source() { # 加载文件 url arg...
    ctx_temp=$(mktemp) && down_source $ctx_temp $1 && shift && source $ctx_temp "$@"
}
down_source() { # 下载文件 dir url
    curl -fsSL $ctx_dev/$2 --create-dirs -o $1
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
        source) # 源码安装
            git clone https://github.com/shylinux/contexts
            cd contexts && source etc/miss.sh
            # ish_miss_serve
            ;;
        binary) # 应用安装
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice && bin/ice.sh serve serve start dev dev "$@"
            ;;
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

            # export ISH_CONF_HUB_PROXY=$ctx_dev/code/git/
            git config --gloal url."https://shylinux.com/code/git/repos".insteadOf "https://github.com/shylinux"
            down_source go.mod publish/go.mod && down_source etc/miss.sh publish/miss.sh && source etc/miss.sh
            ;;
        ice) # 生产环境
            export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
            shift && prepare_ice && bin/ice.sh serve serve start dev dev "$@"
            ;;
        *) # 终端环境
            temp_intshell plug.sh conf.sh
            temp_source publish/order.sh "$@"
            ;;
    esac
}

prepare_main "$@"
