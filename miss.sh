#!/bin/sh

export ctx_pid=${ctx_pid:=var/run/ice.pid}
export ctx_log=${ctx_log:=bin/boot.log}

ish_miss_ice_bin="ice.bin"
ish_miss_init_shy="etc/init.shy"
ish_miss_main_shy="src/main.shy"
ish_miss_main_go="src/main.go"

ish_miss_download_pkg() {
	for url in "$@"; do local pkg=${url##*/}
		[ `ish_sys_file_size $pkg` -gt 0 ] && break
		ish_log_require $url; if curl -h &>/dev/null; then
			curl -o $pkg -fSL $url && tar xf $pkg 
		else
			wget -O $pkg $url && tar xf $pkg 
		fi
	done
}
ish_miss_prepare_compile() {
	ish_sys_path_insert "$PWD/usr/local/go/bin" "$PWD/usr/local/bin" "$PWD/bin" "$PWD/usr/publish"
	export GOPRIVATE=${GOPRIVATE:=shylinux.com,github.com}
	export GOPROXY=${GOPROXY:=https://goproxy.cn,direct}
	export GOBIN=${GOBIN:=$PWD/usr/local/bin}
	export ISH_CONF_PATH=$PWD/.ish/pluged
	export GO111MODULE=on

	go version &>/dev/null && return

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

	local pkg=go${GOVERSION:=1.15.5}.${goos}-${goarch}.tar.gz; ish_log_debug "download: $pkg"
	local back=$PWD; mkdir -p usr/local; cd usr/local; ish_miss_download_pkg https://dl.google.com/go/$pkg; cd $back
}
ish_miss_prepare_develop() {
	require dev/git/git.sh
	ish_dev_git_prepare

	# .gitignore
	ish_sys_file_create .gitignore <<END
etc/
bin/
var/
usr/
.*
END

	# go.mod
	local remote=$(git config remote.origin.url|sed -e "s/^https:\/\///"|sed -e "s/^http:\/\///")
	[ -f go.mod ] || go mod init ${remote:=${PWD##*/}}

	# src/main.go
	ish_sys_file_create $ish_miss_main_go <<END
package main

import "shylinux.com/x/ice"

func main() { print(ice.Run()) }
END

	# Makefile
	ish_sys_file_create Makefile << END
export CGO_ENABLED=0

all:
	@echo && date
	go build -v -o bin/$ish_miss_ice_bin $ish_miss_main_go && ./bin/$ish_miss_ice_bin forever restart
END
}
ish_miss_prepare_install() {
	# etc/init.shy
	ish_sys_file_create $ish_miss_init_shy <<END
~cli

~web

~ssh
	source local.shy

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
}
ish_miss_prepare_intshell() {
	ish_log_require -g shylinux.com/x/intshell
	[ -f $PWD/.ish/plug.sh ] || [ -f $HOME/.ish/plug.sh ] || git clone https://shylinux.com/x/intshell $PWD/.ish
	[ -d $PWD/.ish ] && ish_sys_link_create usr/intshell $PWD/.ish
	[ -d $HOME/.ish ] && ish_sys_link_create usr/intshell $HOME/.ish
	require_pull usr/intshell

	require sys/cli/cli.sh
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
	ish_log_notice "session: $name:$win"

	if ! tmux has-session -t $name &>/dev/null; then
		TMUX="" tmux new-session -d -s $name -n $win
		tmux split-window -d -p 40 -t $name

		if [ "$name" = "miss" ]; then
			tmux send-key -t ${name}:$win.2 "ish_miss_serve_log"
		else
			tmux send-key -t ${name}:$win.2 "ish_miss_space dev dev"
		fi
		sleep 1 && tmux send-key -t ${name}:$win.1 "vim -O src/main.go src/main.shy" Enter

		case `uname -s` in
			Darwin) sleep 3 && open http://localhost:9020 ;;
		esac
	fi

	[ "$TMUX" = "" ] && tmux attach -t $name || tmux select-window -t $name:$win
}

ish_miss_start() {
	while true; do
		date && $ish_miss_ice_bin "$@" 2>$ctx_log && break || echo -e "\n\nrestarting..."
		sleep 1
	done
}
ish_miss_restart() {
	[ -e "$ctx_pid" ] && kill -2 `cat $ctx_pid` &>/dev/null || echo
}
ish_miss_stop() {
	[ -e "$ctx_pid" ] && kill -3 `cat $ctx_pid` &>/dev/null || echo
}
ish_miss_serve_log() {
	ish_miss_stop && ctx_log=/dev/stdout ish_miss_start serve start $@
}
ish_miss_serve() {
	ish_miss_stop && ish_miss_start serve start $@
}
ish_miss_space() {
	ish_miss_stop && ish_miss_start space dial dev ops $@
}
ish_miss_log() {
	touch $ctx_log && tail -f $ctx_log
}

ish_miss_make() {
	local binarys=bin/ice.bin
	echo && date
	[ -f src/version.go ] || echo "package main" > src/version.go
	go build -v -o ${binarys} src/main.go src/version.go && ./${binarys} forever restart &>/dev/null
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
