#!/bin/sh

export ctx_bin=${ctx_bin:=bin/ice.bin}
export ctx_pid=${ctx_pid:=var/log/ice.pid}
export ctx_log=${ctx_log:=var/log/boot.log}
export ctx_shy=${ctx_shy:=https://shylinux.com}
export ctx_dev=${ctx_dev:=https://2021.shylinux.com}

ish_miss_download_pkg() {
	for url in "$@"; do local pkg=${url##*/}; [ `ish_sys_file_size $pkg` -gt 0 ] && break
		ish_log_notice "download: $pkg <= $url"; if curl -h &>/dev/null; then curl -o $pkg -fSL $url; else wget -O $pkg $url; fi
		[ -e "$pkg" ] && if echo $pkg|grep ".zip"; then unzip $pkg; else tar xf $pkg; fi
	done; [ -f "$1" ]
}
ish_miss_prepare_package() {
	case "$(uname)" in
		Darwin) xcode-select --install 2>/dev/null ;;
		Linux) if [ `whoami` != "root" ]; then return; fi
			if cat /etc/os-release|grep alpine &>/dev/null; then
				sed -i 's/dl-cdn.alpinelinux.org/mirrors.tencent.com/g' /etc/apk/repositories && apk update
				TZ=Asia/Shanghai; apk add tzdata && cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
				return
			fi
			if cat /etc/os-release|grep "CentOS-8"&>/dev/null; then
				minorver=8.5.2111; sed -e "s|^mirrorlist=|#mirrorlist=|g" -e "s|^#baseurl=http://mirror.centos.org/\$contentdir/\$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/$minorver|g" -i.bak /etc/yum.repos.d/CentOS-*.repo && yum update -y
			fi
			;;
	esac
}
ish_miss_prepare_compile() {
	export GOVERSION=${GOVERSION:=1.21.4}
	export GOPRIVATE=${GOPRIVATE:=shylinux.com}
	export GOPROXY=${GOPROXY:=https://goproxy.cn}
	export GODOWN=${GODOWN:=https://golang.google.cn/dl/}
	export GOBIN=${GOBIN:=$PWD/usr/local/bin}
	ish_sys_path_insert "$PWD/usr/local/go/bin" "$PWD/usr/local/bin" "$PWD/bin" "$PWD/usr/publish"
	go version &>/dev/null && return
	local goarch=amd64
	case "$(uname -m)" in
		x86_64) goarch=amd64 ;;
		arm64) goarch=arm64 ;;
		i686) goarch=386 ;;
		*) goos=arm ;;
	esac
	local goos=linux
	case "$(uname -s)" in
		Darwin) goos=darwin ;;
		Linux) goos=linux ;;
		*) goos=windows ;;
	esac
	if echo $goos|grep windows; then
		local pkg=go${GOVERSION}.${goos}-${goarch}.zip
	else
		local pkg=go${GOVERSION}.${goos}-${goarch}.tar.gz
	fi
	local back=$PWD; mkdir -p usr/local; cd usr/local
	ish_miss_download_pkg $GODOWN$pkg; cd $back
	# ish_miss_download_pkg $ctx_dev/publish/$pkg $GODOWN$pkg; cd $back
}
ish_miss_prepare_develop() {
	export ISH_CONF_PATH=$PWD/.ish/pluged

	# .gitignore
	ish_sys_file_create ".gitignore" <<END
src/binpack_usr.go
src/binpack.go
src/version.go
etc/local.shy
etc/local.sh
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
binarys = bin/ice.bin
version = src/version.go
binpack = src/binpack.go
flags = -ldflags "-w -s" -v

all: def
	@date +"%Y-%m-%d %H:%M:%S"
	go build \${flags} -o \${binarys} src/main.go \${version} \${binpack} && ./\${binarys} forever restart &>/dev/null

def:
	@[ -f \${version} ] || echo "package main">\${version}
	@[ -f \${binpack} ] || echo "package main">\${binpack}
END
}
ish_miss_prepare_project() {
	# etc/init.shy
	ish_sys_file_create "etc/init.shy" <<END
~ssh
	source local.shy
END

	# etc/exit.shy
	ish_sys_file_create "etc/exit.shy" <<END
~ssh
END

	# src/main.shy
	ish_sys_file_create "src/main.shy" <<END
title "${PWD##*/}"
END
	if ish_miss_isworker && [ -e $HOME/contexts ]; then
		ish_sys_link_create usr/local/daemon $HOME/contexts/usr/local/daemon
		ish_sys_link_create usr/install $HOME/contexts/usr/install
	fi
}

ish_miss_isworker() {
	echo $PWD | grep "usr/local/work/" &>/dev/null
}
ish_miss_prepare() {
	local name=${1##*/} repos=${1#*://}; [ "$name" = "$repos" ] && repos=shylinux.com/x/$name
	if [ -e usr/$name ]; then
		require_pull usr/$name
	else
		ISH_CONF_PATH=$PWD/.ish/pluged require_fork $repos; ish_sys_link_create usr/$name $(require_path $repos)
	fi
}
ish_miss_prepare_contexts() {
	[ -d .git ] || git init; [ "`git remote`" = "" ] || require_pull ./
}
ish_miss_prepare_resource() {
	if echo $PWD | grep "usr/local/work/" &>/dev/null; then
		[ -e usr/icons/ ] || ish_miss_prepare_icons
		[ -e usr/intshell/ ] || ish_miss_prepare_intshell
		[ -e usr/learning/ ] || ish_miss_prepare_learning
		[ -e usr/volcanos/ ] || ish_miss_prepare_volcanos
		[ -e usr/node_modules/ ] || ish_miss_prepare_modules
	else
		ish_miss_prepare_intshell
		ish_miss_prepare_volcanos
		ish_miss_prepare_learning
		ish_miss_prepare_modules
		ish_miss_prepare_icons
	fi
}
ish_miss_prepare_intshell() {
	[ -f $PWD/.ish/plug.sh ] || [ -f $HOME/.ish/plug.sh ] || git clone $ctx_shy/x/intshell $PWD/.ish
	[ -d $PWD/.ish ] && ish_sys_link_create usr/intshell $PWD/.ish
	[ -d $HOME/.ish ] && ish_sys_link_create usr/intshell $HOME/.ish
	require_pull usr/intshell
}
ish_miss_prepare_learning() {
	ish_miss_prepare learning
}
ish_miss_prepare_volcanos() {
	ish_miss_prepare volcanos
}
ish_miss_prepare_toolkits() {
	ish_miss_prepare toolkits
}
ish_miss_prepare_icebergs() {
	ish_miss_prepare icebergs
}
ish_miss_prepare_release() {
	if [ -e usr/release ]; then
		local back=$PWD; cd usr/release; git stash &>/dev/null; git checkout . &>/dev/null; cd $back
	fi
	ish_miss_prepare release
}
ish_miss_prepare_modules() {
	ish_miss_prepare node_modules
}
ish_miss_prepare_icons() {
	ish_miss_prepare icons
}
ish_miss_prepare_file() {
	[ -f $1 ] && return; ish_log_debug -g "create file $1"
	cat > $1
}
ish_miss_prepare_bash() {
	ish_sys_cli_prepare
	ish_sys_link_create ~/.bash_local.sh $PWD/etc/conf/bash_local.sh; source ~/.bash_local.sh
	ish_sys_link_create ~/.vim_local.vim $PWD/etc/conf/vim_local.vim
	ish_dev_git_prepare; ish_dev_vim_prepare; ish_dev_vim_plug_prepare
}
ish_miss_prepare_local() {
	ish_log_debug -g "local file $1"
	ish_miss_prepare_file ../$1/etc/local.shy <<END
source ../${PWD##*/}/etc/private/$1.shy
END
	ish_sys_link_create ../$1/usr/local/export $PWD/etc/export/$1
}
ish_miss_prepare_local_contexts() {
	ish_log_debug -g "local file contexts"
	ish_sys_link_create ~/contexts/usr/local/export $PWD/etc/export/contexts
	ish_miss_prepare_file ~/contexts/etc/local.shy <<END
source ../usr/local/work/${PWD##*/}/etc/private/local.shy
END
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
	local repos back=$PWD; ish_log_pull
	git pull; echo
	for repos in `ls usr/`; do
		if [ -e "usr/$repos/.git" ]; then
			cd "usr/$repos/"; ish_log_pull
			git pull; echo; cd $back
		fi
	done
	if ! [ -e usr/local/work ]; then return; fi
	for repos in `ls usr/local/work/`; do
		if [ -e "usr/local/work/$repos/.git" ]; then
			cd "usr/local/work/$repos/"; ish_log_pull
			git pull; echo; cd $back
		fi
	done
}
ish_miss_each() {
	local repos back=$PWD; ish_log_pull
	"$@"; cat go.mod
	if ! [ -e usr/local/work ]; then return; fi
	for repos in `ls usr/local/work/`; do
		if [ -e "usr/local/work/$repos/.git" ]; then
			cd "usr/local/work/$repos/"; ish_log_pull
			"$@"; cat go.mod; cd $back
		fi
	done
}
ish_miss_push() {
	local repos back=$PWD; ish_log_push
	git push; git push --tags; echo
	for repos in `ls usr/`; do
		if [ -e "usr/$repos/.git" ]; then
			cd "usr/$repos/"; ish_log_push
			git push; git push --tags; echo; cd $back
		fi
	done
	if ! [ -e usr/local/work ]; then return; fi
	for repos in `ls usr/local/work/`; do
		if [ -e "usr/local/work/$repos/.git" ]; then
			cd "usr/local/work/$repos/"; ish_log_push
			git push; git push --tags; echo; cd $back
		fi
	done
}
ish_miss_make_all() {
	if ! [ -e usr/local/work ]; then return; fi
	local back=$PWD;
	for repos in `ls usr/local/work/`; do
		if [ -e "usr/local/work/$repos/.git" ]; then
			cd "usr/local/work/$repos/"; ish_miss_make; echo; cd $back
		fi
	done
}
ish_miss_make() {
	local binarys=$ctx_bin; echo && date +"%Y-%m-%d %H:%M:%S make $PWD"
	[ -f src/version.go ] || echo "package main" > src/version.go
	[ -f src/binpack.go ] || echo "package main" > src/binpack.go
	CGO_ENABLED=0 go build -ldflags "-w -s" -v -o ${binarys} src/main.go src/version.go src/binpack.go && ./${binarys} forever restart &>/dev/null
}
ish_miss_start() {
	[ -n "${ctx_log}" ] && echo $ctx_log|grep "/" &>/dev/null && mkdir -p ${ctx_log%/*}
	ish_sys_path_load
	while true; do
		[ -f "var/log/boot.log" ] && grep "concurrent map read and map write" "var/log/boot.log" &>/dev/null && mv "var/log/boot.log" "var/log/$(ish_sys_date_filename)_boot.log"
		$PWD/$ctx_bin "$@" 2>${ctx_log:="/dev/stdout"} && break
	done
}
ish_miss_restart() {
	$ctx_bin forever restart
}
ish_miss_stop() {
	$ctx_bin forever stop
}
ish_miss_list() {
	# ps aux| grep -v grep| grep $ctx_bin
	ps aux| grep -v grep| grep $ctx_bin | grep "$PWD/usr/local/work/"
}
ish_miss_killall() {
	ish_miss_list | awk '{print $2}' | xargs kill
}
ish_miss_log() {
	touch $ctx_log && tail -f $ctx_log
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
ish_miss_admin() {
	$ctx_bin web.admin "$@"
}
ish_miss_app() {
	ish_miss_stop && $ctx_bin forever ./usr/publish/contexts.app/Contents/MacOS/contexts
}
ish_miss_app_log() {
	ctx_log=/dev/stdout ish_miss_app "$@"
}
