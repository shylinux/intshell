#!/bin/sh

export ctx_log=${ctx_log:=/dev/null}
export ctx_dev=${ctx_dev:="https://shylinux.com"}
export ctx_dev_ip=${ctx_dev_ip:="$ctx_dev"}
export ctx_repos=${ctx_repos:="https://shylinux.com/x/ContextOS"}
export ctx_name=${ctx_name:="$ctx_pod"}
export ctx_name=${ctx_name:="${ctx_repos##*/}"}
export ctx_name=${ctx_name:="ContextOS"}

_down_big_file() {
	[ -f "$1" ] && return; echo "download $ctx_dev_ip/$2"
	if curl -h &>/dev/null; then curl -o $1 --connect-timeout 3 -fL "$ctx_dev_ip/$2?pod=$ctx_pod"; else wget -O $1 "$ctx_dev_ip/$2?pod=$ctx_pod"; fi
	[ -f "$1" ] && return; echo "download $ctx_dev/$2"; export ctx_dev_ip=
	if curl -h &>/dev/null; then curl -o $1 -fL "$ctx_dev/$2?pod=$ctx_pod"; else wget -O $1 "$ctx_dev/$2?pod=$ctx_pod"; fi
}
_down_file() {
	if curl -h &>/dev/null; then curl -o $1 -fsSL "$ctx_dev/$2"; else wget -O $1 -q "$ctx_dev/$2"; fi
}
_temp_file() {
	local temp=$(mktemp) && _down_file $temp $1 && shift && source $temp "$@"
}
prepare_script() {
	_temp_file plug.sh && require conf.sh
}
prepare_system() {
	case "$(uname)" in
		Darwin) xcode-select --install 2>/dev/null ;;
		Linux)
			if [ `whoami` != "root" ]; then return; fi
			if cat /etc/os-release|grep alpine &>/dev/null; then
				git version &>/dev/null || apk add git
				go version &>/dev/null || apk add go
				npm version &>/dev/null || apk add npm
			elif cat /etc/os-release|grep "rhel"&>/dev/null; then
				git version &>/dev/null || yum install -y git
				go version &>/dev/null || yum install -y go
				npm version &>/dev/null || yum install -y npm
			fi
			git config --global credential.helper store
			;;
	esac
}
prepare_ice() {
	local bin="ice"
	case `uname -s` in
		Darwin) bin=${bin}.darwin ;;
		Linux) bin=${bin}.linux ;;
		*) bin=${bin}.windows ;;
	esac
	case `uname -m` in
		mips) bin=${bin}.mipsle ;;
		x86_64) bin=${bin}.amd64 ;;
		arm64) bin=${bin}.amd64 ;;
		arm*|aarch64) bin=${bin}.arm ;;
		*) bin=${bin}.386 ;;
	esac
	local file=bin/ice.bin; [ -e bin ] || mkdir bin
	_down_big_file $file publish/$bin && chmod u+x $file; [ -f $file ]
}
prepare_reload() {
	local temp=$(mktemp); if curl -V &>/dev/null; then curl -o $temp -fsSL $ctx_dev; else wget -O $temp -q $ctx_dev; fi && source $temp $ctx_mod
}
main() {
	case "$1" in
		binary) shift
			[ -e $ctx_name ] || mkdir $ctx_name; cd $ctx_name
			[ -e /opt/daemon/ ] && mkdir -p usr/local/ && ln -s /opt/daemon/ usr/local/daemon
			prepare_ice && $PWD/bin/ice.bin forever start "$@"
			;;
		source) shift
			prepare_system; [ -e $ctx_name ] || git clone $ctx_repos $ctx_name; cd $ctx_name
			source etc/miss.sh && $PWD/bin/ice.bin forever start "$@"
			;;
		intshell)
			[ -f $PWD/.ish/plug.sh ] && source $PWD/.ish/plug.sh && return
			[ -f $HOME/.ish/plug.sh ] && source $HOME/.ish/plug.sh && return
			prepare_system; git clone $ctx_dev/x/intshell $PWD/.ish
			source $PWD/.ish/plug.sh; require conf.sh; require miss.sh
			;;
		*)
			prepare_script; if echo $1|grep ".sh$" &>/dev/null; then require "$@"; else require src/main.sh "$@"; fi
			;;
	esac
}
main "$@"
