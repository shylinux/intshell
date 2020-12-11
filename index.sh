#!/bin/sh

temp_source() {
    for script in "$@"; do
        ctx_temp=$(mktemp); curl -fsSL $ctx_dev/intshell/$script >$ctx_temp; source $ctx_temp
    done 
}
prepare_tmux() {
    [ -d "etc" ] || mkdir etc
    [ -f "etc/tmux.conf" ] || curl -fsSL $ctx_dev/intshell/misc/tmux/tmux.conf -o etc/tmux.conf

    [ -d "bin" ] || mkdir bin
    [ -f "bin/tmux.sh" ] || cat <<END >>bin/tmux.sh
#!/bin/bash

tmux_cmd="tmux -S bin/tmux.socket -f etc/tmux.conf"
session=miss && [ -s "\$1" ] && session=\$1 && shift

if \$tmux_cmd has-session -t \$session; then
    \$tmux_cmd attach -t \$session
else
    \$tmux_cmd new-session -s \$session
fi
END
    chmod u+x bin/tmux.sh
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
                curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && yum -y update
                yum install -y wget make tmux git vim
                ;;
            *)
                ;;
        esac

        # [ -d contexts ] || git clone --depth 1 https://github.com/shylinux/contexts $PWD/contexts
        [ -d contexts ] || git clone --depth 1 https://gitee.com/shylinuxc/contexts $PWD/contexts
        ISH_CTX_CLONE_SIMPLE=true cd contexts && source etc/miss.sh
        ;;
    ice) # 生产环境
        prepare_tmux

        export ctx_log=${ctx_log:=/dev/stdout}
        mkdir bin &>/dev/null; curl -fsSL $ctx_dev/publish/ice.sh -o bin/ice.sh && chmod u+x bin/ice.sh && bin/ice.sh serve serve start dev dev
        ;;
    *) # 终端环境
        temp_source plug.sh conf.sh
esac
