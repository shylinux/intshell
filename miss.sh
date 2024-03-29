#!/bin/sh

export ctx_bin=${ctx_bin:=ice.bin}
export ctx_pid=${ctx_pid:=var/log/ice.pid}
export ctx_log=${ctx_log:=var/log/boot.log}

ish_miss_download_pkg() {
	for url in "$@"; do local pkg=${url##*/}; [ `ish_sys_file_size $pkg` -gt 0 ] && break
		ish_log_notice "download: $pkg <= $url"; if curl -h &>/dev/null; then curl -o $pkg -fSL $url; else wget -O $pkg $url; fi
		! [ -e "$pkg" ] && continue
		if echo $pkg|grep ".zip"; then unzip $pkg; else tar xf $pkg; fi
	done
	[ -f "$1" ]
}
ish_miss_prepare_compile() {
	ish_sys_path_insert "$PWD/usr/local/go/bin" "$PWD/usr/local/bin" "$PWD/bin" "$PWD/usr/publish"
	export GOVERSION=${GOVERSION:=1.20.3}
	export GOPRIVATE=${GOPRIVATE:=shylinux.com}
	export GOPROXY=${GOPROXY:=https://goproxy.cn}
	export GODOWN=${GODOWN:=https://golang.google.cn/dl/}
	export GOBIN=${GOBIN:=$PWD/usr/local/bin}
	go version |grep ${GOVERSION} &>/dev/null && return
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
	if echo $goos|grep windows; then
		local pkg=go${GOVERSION}.${goos}-${goarch}.zip
	else
		local pkg=go${GOVERSION}.${goos}-${goarch}.tar.gz
	fi; local back=$PWD; mkdir -p usr/local; cd usr/local
	ish_miss_download_pkg ${ctx_dev:="http://localhost:9020"}/publish/$pkg $GODOWN$pkg; cd $back
	ish_sys_path_insert usr/local/go
}
ish_miss_prepare_develop() {
	export ISH_CONF_PATH=$PWD/.ish/pluged

	# .gitignore
	ish_sys_file_create ".gitignore" <<END
src/binpack.go
src/version.go
etc/
bin/
var/
usr/
.*
END

	# go.mod
	local remote=$(git config remote.origin.url|sed -e "s/^https*:\/\///")
	[ -f go.mod ] || go mod init ${remote:=${PWD##*/}}

	# src/main.go
	ish_sys_file_create "src/main.go" <<END
package main

import "shylinux.com/x/ice"

func main() { print(ice.Run()) }
END

	# Makefile
	ish_sys_file_create Makefile << END
export CGO_ENABLED=0

binarys = bin/ice.bin

all: def
	@echo && date
	go build -v -o \${binarys} src/main.go src/version.go src/binpack.go && ./\${binarys} forever restart &>/dev/null

def:
	@ [ -f src/version.go ] || echo "package main" > src/version.go
	@ [ -f src/binpack.go ] || echo "package main" > src/binpack.go
END
}
ish_miss_prepare_project() {
	# etc/init.shy
	ish_sys_file_create "etc/init.shy" <<END
~aaa

~web

~ssh
	source local.shy
END

	# src/main.shy
	ish_sys_file_create "src/main.shy" <<END
title "${PWD##*/}"
END
}

ish_miss_prepare() {
	local name=${1##*/} repos=${1#*://}; [ "$name" = "$repos" ] && repos=shylinux.com/x/$name
	ISH_CONF_PATH=$PWD/.ish/pluged require_fork $repos; ish_sys_link_create usr/$name $(require_path $repos); require_pull usr/$name
}
ish_miss_prepare_intshell() {
	require sys/cli/cli.sh
	ish_log_require -g shylinux.com/x/intshell
	[ -f $PWD/.ish/plug.sh ] || [ -f $HOME/.ish/plug.sh ] || git clone https://shylinux.com/x/intshell $PWD/.ish
	[ -d $PWD/.ish ] && ish_sys_link_create usr/intshell $PWD/.ish
	[ -d $HOME/.ish ] && ish_sys_link_create usr/intshell $HOME/.ish
	require_pull usr/intshell
}
ish_miss_prepare_contexts() {
	ish_log_require -g shylinux.com/x/contexts
	[ -d .git ] || git init; [ "`git remote`" = "" ] || require_pull ./
}
ish_miss_prepare_toolkits() {
	ish_miss_prepare toolkits
}
ish_miss_prepare_icebergs() {
	ish_miss_prepare icebergs
}
ish_miss_prepare_release() {
	ish_miss_prepare release
}
ish_miss_prepare_volcanos() {
	ish_miss_prepare volcanos
}
ish_miss_prepare_learning() {
	ish_miss_prepare learning
}
ish_miss_prepare_bash() {
	ish_sys_cli_prepare
	ish_sys_link_create ~/.bash_local.sh $PWD/etc/conf/bash_local.sh; source ~/.bash_local.sh
	ish_sys_link_create ~/.vim_local.vim $PWD/etc/conf/vim_local.vim
	ish_dev_git_prepare
	ish_dev_vim_prepare
	ish_dev_vim_plug_prepare
	ish_dev_tmux_prepare
	if tmux -V; then ish_miss_prepare_session miss miss; else ish_miss_serve_log; fi
}
ish_miss_prepare_session() {
	local name=$1 && [ "$name" = "" ] && name=${PWD##*/}
	local win=$2 && [ "$win" = "" ] && win=${name%%-*}
	ish_log_notice "session: $name:$win"
	if ! tmux has-session -t $name &>/dev/null; then
		TMUX="" tmux new-session -d -s $name -n $win; tmux split-window -d -p 40 -t $name
		if [ "$name" = "miss" ]; then
			tmux send-key -t ${name}:$win.2 "ish_miss_serve_log" Enter
		else
			tmux send-key -t ${name}:$win.2 "ish_miss_space dev ops" Enter
		fi
		sleep 1 && tmux send-key -t ${name}:$win.1 "vim -O src/main.go src/main.shy" Enter
	fi
	[ "$TMUX" = "" ] && tmux attach -t $name || tmux select-window -t $name:$win
}

ish_miss_pull() {
	local repos back=$PWD
	ish_log_notice "repos $PWD"
	git pull; echo
	for repos in `ls usr/`; do
		if [ -e "usr/$repos/.git" ]; then
			cd "usr/$repos/"; ish_log_notice "repos $PWD"
			git pull; echo
			cd $back
		fi
	done
	for repos in `ls usr/local/work/`; do
		if [ -e "usr/local/work/$repos/.git" ]; then
			cd "usr/local/work/$repos/"; ish_log_notice "repos $PWD"
			git pull; echo
			cd $back
		fi
	done
}
ish_miss_push() {
	local repos back=$PWD
	ish_log_notice "repos $PWD"
	git push; git push --tags; echo
	for repos in `ls usr/`; do
		if [ -e "usr/$repos/.git" ]; then
			cd "usr/$repos/"; ish_log_notice "repos $PWD"
			git push; git push --tags; echo
			cd $back
		fi
	done
	for repos in `ls usr/local/work/`; do
		if [ -e "usr/local/work/$repos/.git" ]; then
			cd "usr/local/work/$repos/"; ish_log_notice "repos $PWD"
			git push; git push --tags; echo
			cd $back
		fi
	done
}
ish_miss_make() {
 	local binarys=bin/ice.bin; echo && date
	[ -f src/version.go ] || echo "package main" > src/version.go
	[ -f src/binpack.go ] || echo "package main" > src/binpack.go
	CGO_ENABLED=0 go build -ldflags "-w -s" -v -o ${binarys} src/main.go src/version.go src/binpack.go && ./${binarys} forever restart
}
ish_miss_start() {
	[ -n "${ctx_log}" ] && echo $ctx_log|grep "/" &>/dev/null && mkdir -p ${ctx_log%/*}
	ish_sys_path_load; while true; do
		[ -f "var/log/boot.log" ] && grep "concurrent map read and map write" "var/log/boot.log" &>/dev/null && mv "var/log/boot.log" "var/log/$(ish_sys_date_filename)_boot.log"
   		ice.bin "$@" 2>${ctx_log:="/dev/stdout"} && break
	done
}
ish_miss_restart() {
	$ctx_bin forever restart
}
ish_miss_stop() {
	$ctx_bin forever stop
}
ish_miss_log() {
	touch $ctx_log && tail -f $ctx_log
}
ish_miss_serve_log_clear() {
	clear; tmux clear-history
	tmux set history-limit 20000
	ctx_log=/dev/stdout ish_miss_serve "$@"
}
ish_miss_serve_log() {
	ctx_log=/dev/stdout ish_miss_serve "$@"
}
ish_miss_serve() {
	ish_miss_stop && ish_miss_start serve start dev "" "$@"
}
ish_miss_space() {
	ish_miss_stop && ish_miss_start space start dev ops "$@"
}
ish_miss_space_log() {
	ctx_log=/dev/stdout ish_miss_space "$@"
}
ish_miss_app() {
	ish_miss_stop && $ctx_bin forever ./usr/publish/contexts.app/Contents/MacOS/contexts
}
ish_miss_app_log() {
	ctx_log=/dev/stdout ish_miss_app "$@"
}
ish_miss_killall() {
	ps aux|grep ice.bin|grep -v grep|awk '{print $2}'|xargs kill
}
