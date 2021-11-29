#!/bin/sh

export ctx_dev=${ctx_dev:="$ISH_CONF_DEV"}
export ctx_pid=${ctx_pid:=var/run/ice.pid}
export ctx_log=${ctx_log:=bin/boot.log}

require sys/cli/file.sh

ish_miss_ice_bin="ice.bin"
ish_miss_ice_sh="bin/ice.sh"
ish_miss_miss_sh="etc/miss.sh"
ish_miss_init_shy="etc/init.shy"
ish_miss_main_shy="src/main.shy"
ish_miss_main_go="src/main.go"

ish_miss_download_pkg() {
    for url in "$@"; do local pkg=${url##*/}
        [ `ish_sys_file_size $pkg` -gt 0 ] && break
        ish_log_require $ctx_dev/publish/$pkg
        curl -fSOL $ctx_dev/publish/$pkg && tar xf $pkg 

        [ `ish_sys_file_size $pkg` -gt 0 ] && break
        ish_log_require $url
        curl -fSOL $url && tar xf $pkg 
    done
}
ish_miss_prepare_compile() {
    ish_sys_path_insert "$PWD/usr/local/go/bin" "$PWD/usr/local/bin" "$PWD/bin" "$PWD/usr/publish"
    export GOPROXY=${GOPROXY:=https://goproxy.cn,direct}
    export GORPIVATE=${GOPRIVATE:=github.com}
    export GOROOT=${GOROOT:=$PWD/usr/local/go}
    export GOBIN=${GOBIN:=$PWD/usr/local/bin}
    export ISH_CONF_PATH=$PWD/.ish/pluged
    export GOSUMDB=off
    [ -f "$GOROOT/bin/go" ] && return

    local goarch=amd64; case "$(uname -m)" in
        x86_64) goarch=amd64;;
        arm64) goarch=arm64;;
        i686) goarch=386;;
        *) goos=arm;;
    esac
    local goos=linux; case "$(uname -s)" in
        Darwin) goos=darwin;;
        Linux) goos=linux;;
        *) goos=windows;;
    esac

    local pkg=go${GOVERSION:=1.17.3}.${goos}-${goarch}.tar.gz
    local back=$PWD; mkdir -p usr/local; cd usr/local; ish_miss_download_pkg https://dl.google.com/go/$pkg; cd $back
}
ish_miss_prepare_develop() {
    declare|grep "^ish_dev_git_prepare ()" &>/dev/null || require dev/git/git.sh
    ish_dev_git_prepare

    # .gitignore
    ish_sys_file_create .gitignore <<END
src/binpack.go
src/version.go
etc/local.shy
etc/local.sh
etc/path
*.swp
*.swo
bin/
var/
usr/
.*

END

    # src/main.go
    ish_sys_file_create $ish_miss_main_go <<END
package main

import "shylinux.com/x/ice"

func main() { print(ice.Run()) }
END
    [ -f go.mod ] || go mod init ${PWD##*/}

    # Makefile
    ish_sys_file_create Makefile << END
export GOPROXY=https://goproxy.cn,direct
export GOPRIVATE=shylinux.com,github.com
export CGO_ENABLED=0

all:
	@echo && date
	go build -v -o bin/$ish_miss_ice_bin $ish_miss_main_go && chmod u+x bin/$ish_miss_ice_bin && chmod u+x $ish_miss_ice_sh && ./$ish_miss_ice_sh restart
END

    # bin/ice.sh
    ish_sys_file_create $ish_miss_ice_sh <<END
#! /bin/sh

export ctx_log=\${ctx_log:=bin/boot.log}
export ctx_pid=\${ctx_pid:=var/run/ice.pid}

start() {
    trap HUP hup && while true; do
        date && bin/$ish_miss_ice_bin \$@ 2>\$ctx_log && break || echo -e "\n\nrestarting..." 
    done
}
restart() {
    [ -e \$ctx_pid ] && kill -2 \`cat \$ctx_pid\` &>/dev/null || echo
}
stop() {
    [ -e \$ctx_pid ] && kill -3 \`cat \$ctx_pid\` &>/dev/null || echo
}
serve() {
    stop && start "\$@"
}

cmd=\$1 && [ -n \"\$cmd\" ] && shift || cmd="start space dial dev dev"
\$cmd "\$@"
END
    chmod u+x $ish_miss_ice_sh
}
ish_miss_prepare_install() {
    # etc/init.shy
    ish_sys_file_create $ish_miss_init_shy <<END
~aaa

~web

~cli

~ctx

~mdb

END

    # src/main.shy
    ish_sys_file_create $ish_miss_main_shy <<END
title "${PWD##*/}"
END
}

ish_miss_prepare() {
    local name=${1##*/} repos=${1#https://}
    [ "$name" = "$repos" ] && repos=shylinux.com/x/$name

    local back=$PWD
    ISH_CONF_PATH=$PWD/.ish/pluged require $repos
    ish_sys_link_create usr/$name $(require_path $repos)
    require_pull usr/$name
    cd $back
}
ish_miss_prepare_contexts() {
    ish_log_require -g shylinux.com/x/contexts
    [ -d .git ] || git init
    [ "`git remote`" = "" ] || require_pull ./
    ish_sys_file_create etc/conf/bash_local.sh <<END
#!/bin/bash

END
    ish_sys_file_create etc/conf/vim_local.vim <<END

END
}
ish_miss_prepare_intshell() {
    ish_log_require -g shylinux.com/x/intshell
    [ -f $PWD/.ish/plug.sh ] || [ -f $HOME/.ish/plug.sh ] || git clone ${ISH_CONF_HUB_PROXY:="https://"}shylinux.com/x/intshell $PWD/.ish
    [ -d $PWD/.ish ] && ish_sys_link_create usr/intshell $PWD/.ish
    [ -d $HOME/.ish ] && ish_sys_link_create usr/intshell $HOME/.ish
    require_pull usr/intshell

    declare|grep "^ish_sys_cli_prepare ()" &>/dev/null || require sys/cli/cli.sh
    ish_sys_cli_prepare
}
ish_miss_prepare_icebergs() {
    ish_miss_prepare icebergs
}
ish_miss_prepare_toolkits() {
    ish_miss_prepare toolkits
}
ish_miss_prepare_volcanos() {
    ish_miss_prepare volcanos
}
ish_miss_prepare_learning() {
    ish_miss_prepare learning
}
ish_miss_prepare_session() {
    local name=$1 && [ "$name" = "" ] && name=${PWD##*/}
    local win=$2 && [ "$win" = "" ] && win=${name##*-}
    ish_log_debug "session: $name:$win"

    if ! tmux has-session -t $name &>/dev/null; then
        TMUX="" tmux new-session -d -s $name -n $win
        tmux split-window -d -p 30 -t $name
        tmux split-window -d -h -t ${name}:$win.2

        local left=2 right=3
        tmux send-key -t ${name}:$win.$right "ish_miss_log" Enter
        if [ "$name" = "miss" ]; then
            tmux send-key -t ${name}:$win.$left "ish_miss_serve" Enter
        else
            tmux send-key -t ${name}:$win.$left "ish_miss_space dev dev" Enter
        fi
        sleep 1 && tmux send-key -t ${name}:$win.1 "vim -O src/main.go src/main.shy" Enter

        case `uname -s` in
            Darwin) sleep 5 && open http://localhost:9020 ;;
        esac
    fi

    [ "$TMUX" = "" ] && tmux attach -t $name || tmux select-window -t $name:$win
}

ish_miss_start() {
    while true; do
        date && $ish_miss_ice_bin $@ 2>$ctx_log && break || echo -e "\n\nrestarting..."
    done
}
ish_miss_restart() {
    [ -e "$ctx_pid" ] && kill -2 `cat $ctx_pid` &>/dev/null || echo
}
ish_miss_stop() {
    [ -e "$ctx_pid" ] && kill -3 `cat $ctx_pid` &>/dev/null || echo
}
ish_miss_serve() {
    ish_miss_stop && ish_miss_start serve start $@
}
ish_miss_space() {
    ish_miss_stop && ish_miss_start space dial $@
}
ish_miss_log() {
    touch $ctx_log && tail -f $ctx_log
}

ish_miss_publish() {
    for file in "$@"; do
        cp $file usr/publish/
    done
}
ish_miss_make() {
    echo && date
    [ -f src/version.go ] || echo "package main" > src/version.go
    go build -v -o bin/ice.bin src/main.go src/version.go && chmod u+x bin/ice.bin && ./bin/ice.sh restart
}

ish_miss_go_sum() {
    go mod download shylinux.com/x/ice
    go mod download shylinux.com/x/icebergs
    go mod download shylinux.com/x/toolkits
    
    go mod download shylinux.com/x/websocket
    go mod download shylinux.com/x/go-qrcode
    go mod download shylinux.com/x/go-sql-mysql
    
    go mod download shylinux.com/x/linux-story
    go mod download shylinux.com/x/nginx-story
    go mod download shylinux.com/x/golang-story
    go mod download shylinux.com/x/redis-story
    go mod download shylinux.com/x/mysql-story

}
