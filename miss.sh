#!/bin/sh

export ctx_dev=${ctx_dev:="$ISH_CONF_DEV"}
export ctx_pid=${ctx_pid:=var/run/ice.pid}
export ctx_log=${ctx_log:=bin/boot.log}

ish_miss_ice_sh="bin/ice.sh"
ish_miss_ice_bin="bin/ice.bin"
ish_miss_miss_sh="etc/miss.sh"
ish_miss_main_go="src/main.go"
ish_miss_main_shy="src/main.shy"
ish_miss_init_shy="etc/init.shy"
ish_miss_order_js="usr/publish/order.js"

ish_miss_create_path() {
    local target=$1 && [ -d ${target%/*} ] && return
    [ ${target%/*} != ${target} ] && mkdir -p ${target%/*} || return 0
}
ish_miss_create_file() {
    [ -e $1 ] && return || ish_log_debug -g "create file ${PWD} $1"
    ish_miss_create_path $1 && cat > $1
}
ish_miss_create_link() {
    [ -e $1 ] && return || ish_log_debug -g "create link $1 => $2"
    ish_miss_create_path $1 && ln -s $2 $1
}

ish_miss_prepare_develop() {
    echo $PATH| grep "$PWD/usr/local/go/bin" &>/dev/null || export PATH=$PWD/usr/local/go/bin:$PATH
    echo $PATH| grep "$PWD/usr/local/bin" &>/dev/null || export PATH=$PWD/usr/local/bin:$PATH
    echo $PATH| grep "$PWD/bin" &>/dev/null || export PATH=$PWD/bin:$PATH
    export GOPROXY=${GOPROXY:=https://goproxy.cn,direct}
    export GORPIVATE=${GOPRIVATE:=github.com}
    export GOROOT=${GOROOT:=$PWD/usr/local/go}
    export GOBIN=${GOBIN:=$PWD/usr/local/bin}
    export ISH_CONF_PATH=$PWD/.ish/pluged
    [ -d "$GOROOT" ] && return

    local goarch=amd64; case "$(uname -m)" in
        x86_64) goarch=amd64;;
        i686) goarch=386;;
        *) goos=arm;;
    esac
    local goos=linux; case "$(uname -s)" in
        Darwin) goos=darwin;;
        Linux) goos=linux;;
        *) goos=windows;;
    esac
    local pkg=go${GOVERSION:=1.15.5}.${goos}-${goarch}.tar.gz

    ish_log_require "$pkg"
    mkdir -p usr/local; cd usr/local
    curl -O https://dl.google.com/go/$pkg || wget https://dl.google.com/go/$pkg
    tar xvf $pkg
    cd -

    vim -c GoInstallBinaries -c exit -c exit
}
ish_miss_prepare_compile() {
    export ISH_CONF_TASK=${PWD##*/}
    ish_miss_create_file $ish_miss_ice_sh <<END
#! /bin/sh

export ctx_log=\${ctx_log:=bin/boot.log}
export ctx_pid=\${ctx_pid:=var/run/ice.pid}

restart() {
    [ -e \$ctx_pid ] && kill -2 \`cat \$ctx_pid\` &>/dev/null || echo
}
start() {
    trap HUP hup && while true; do
        echo -e "\n\nrestarting..." && date && $ish_miss_ice_bin \$@ 2>\$ctx_log && break
    done
}
stop() {
    [ -e \$ctx_pid ] && kill -3 \`cat \$ctx_pid\` &>/dev/null || echo
}
serve() {
    stop
    start \$@
}

cmd=\$1 && [ -n \"\$cmd\" ] && shift || cmd="start space connect dev dev"
\$cmd \$*
END
    chmod u+x $ish_miss_ice_sh

    ish_miss_create_file $ish_miss_main_go <<END
package main

import (
	ice "github.com/shylinux/icebergs"
	_ "github.com/shylinux/icebergs/base"
	_ "github.com/shylinux/icebergs/core"
	_ "github.com/shylinux/icebergs/misc"
)

func main() { print(ice.Run()) }
END
    [ -f go.mod ] || go mod init ${PWD##*/}

    ish_miss_create_file Makefile << END
export GOPROXY=https://goproxy.cn,direct
export GOPRIVATE=github.com
export CGO_ENABLED=0

all:
	@echo && date
	go build -v -o $ish_miss_ice_bin $ish_miss_main_go && chmod u+x $ish_miss_ice_bin && chmod u+x $ish_miss_ice_sh && ./$ish_miss_ice_sh restart
END
}
ish_miss_prepare_install() {
    ish_miss_create_file $ish_miss_init_shy <<END
~cli

~aaa

~web

~mdb

~ssh

END

    ish_miss_create_file $ish_miss_main_shy <<END
title main
END

    ish_miss_create_file $ish_miss_order_js <<END
Volcanos("onengine", {})
END
}
ish_miss_prepare_session() {
    local name=$1 && [ "$name" = "" ] && name=${PWD##*/}
    local win=$2 && [ "$win" = "" ] && win=${name##*-}
    ish_log_debug "session: $name:$win"

    if ! tmux has-session -t $name; then
        TMUX="" tmux new-session -d -s $name -n $win
        tmux split-window -d -p 30 -t $name
        tmux split-window -d -h -t ${name}:$win.2

        local left=3 right=2; case "$(uname -s)" in
            Darwin) left=2 right=3;;
        esac

        tmux send-key -t ${name}:$win.$right "ish_miss_log" Enter
        if [ "$name" = "miss" ]; then
            tmux send-key -t ${name}:$win.$left "ish_miss_serve dev shy" Enter
        else
            tmux send-key -t ${name}:$win.$left "ish_miss_space dev dev" Enter
        fi
        tmux send-key -t ${name}:$win.1 "vim -O src/main.go src/main.shy" Enter
    fi

    [ "$TMUX" = "" ] && tmux attach -t $name || tmux select-window -t $name:$win
}

ish_miss_prepare() {
    ISH_CONF_PATH=$PWD/.ish/pluged
    for repos in "$@"; do local name=${repos##*/}
        [ "$name" = "$repos" ] && repos=shylinux/$name
        [ "$repos" = "shylinux/$name" ] && repos=github.com/shylinux/$name
        repos=${repos#https://}; require $repos
        ish_miss_create_link usr/$name $(require_path $repos)
        require_pull usr/$name
    done
}
ish_miss_prepare_contexts() {
    ish_log_require "as ctx $(_color g github.com/shylinux/contexts)"
    require_pull ./
}
ish_miss_prepare_intshell() {
    ish_log_require "as ctx $(_color g github.com/shylinux/intshell)"
    ish_miss_create_link usr/intshell $PWD/.ish
    require_pull usr/intshell

    declare|grep "^ish_ctx_cli_prepare ()" &>/dev/null || require base/cli/cli.sh
    ish_ctx_cli_prepare
}
ish_miss_prepare_toolkits() {
    ish_miss_prepare toolkits
}
ish_miss_prepare_icebergs() {
    ish_miss_prepare icebergs
}
ish_miss_prepare_learning() {
    ish_miss_prepare learning
}
ish_miss_prepare_volcanos() {
    ish_miss_prepare volcanos
}

ish_miss_stop() {
    [ -e "$ctx_pid" ] && kill -3 `cat $ctx_pid` &>/dev/null
}
ish_miss_restart() {
    [ -e "$ctx_pid" ] && kill -2 `cat $ctx_pid` &>/dev/null
}
ish_miss_start() {
    while true; do
        date && $ish_miss_ice_bin $@ 2>$ctx_log && break || echo -e "\n\nrestarting..."
    done
}
ish_miss_space() {
    ish_miss_stop
    ish_miss_start space connect $@
}
ish_miss_serve() {
    ish_miss_stop
    ish_miss_start serve start $@
}
ish_miss_log() {
    tail -f $ctx_log
}
ish_miss_version() {
    cat > src/version.go <<END
package main

import (
	"github.com/shylinux/icebergs"
)

func init() {
	ice.Info.Build.Time = \`$(date +"%Y-%m-%d %H:%M:%S")\`
	ice.Info.Build.Hash = \`$(git log -n1 --pretty="%H")\`
	ice.Info.Build.Remote = \`$(git config remote.origin.url)\`
	ice.Info.Build.Branch = \`$(git rev-parse --abbrev-ref HEAD)\`
    ice.Info.Build.Version = \`$(git describe --tags)\`
    ice.Info.Build.HostName = \`$(hostname)\`
    ice.Info.Build.UserName = \`$(whoami)\`
}
END
}

