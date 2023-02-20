#!/bin/sh

export ctx_dev=${ctx_dev:="https://shylinux.com"}

_down_big_file() { # 下载文件 dir url
	[ -f "$1" ] && return || echo "download $ctx_dev/$2"
	echo $1| grep "/" &>/dev/null && mkdir -p ${1%*/*}; if curl -h &>/dev/null; then
		curl -o $1 -fL "$ctx_dev/$2?pod=$ctx_pod"
	else
		wget -O $1 "$ctx_dev/$2?pod=$ctx_pod"
	fi
}
_down_file() { # 下载文件 dir url
	echo $1| grep "/" &>/dev/null && mkdir -p ${1%*/*}; if curl -h &>/dev/null; then
		curl -o $1 -fsSL $ctx_dev/$2
	else
		wget -O $1 -q $ctx_dev/$2
	fi
}
_temp_file() { # 加载文件 url arg...
	ctx_temp=$(mktemp) && _down_file $ctx_temp $1 && shift && source $ctx_temp "$@"
}
prepare_script() {
	_temp_file plug.sh && require conf.sh
}
prepare_system() {
	case "$(uname)" in
		Darwin) xcode-select --install 2>/dev/null ;;
		Linux) 
			echo "yum install make git vim tmux"
			if [ `whoami` == root ]; then
				# apk add git
				yum install -y make git vim tmux
			else
				sudo yum install -y make git vim tmux
			fi
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
	_down_big_file bin/ice.bin publish/$bin && chmod u+x bin/ice.bin; [ -f bin/ice.bin ]
}
main() {
	case "$1" in
		intshell) # 安装环境
			[ -f $PWD/.ish/plug.sh ] && source $PWD/.ish/plug.sh && return
			[ -f $HOME/.ish/plug.sh ] && source $HOME/.ish/plug.sh && return
			prepare_system && git clone https://shylinux.com/x/intshell $PWD/.ish
			source $PWD/.ish/plug.sh; require conf.sh; require miss.sh
			;;
		source) # 源码安装
			prepare_system && git clone https://shylinux.com/x/contexts
			shift && cd contexts && source etc/miss.sh "$@"
			;;
		binary) # 应用安装
			shift && prepare_ice && bin/ice.bin forever start dev "" "$@"
			;;
		*) # 终端环境
			prepare_script; if echo $1|grep ".sh$" &>/dev/null; then require "$@"; else require src/main.sh "$@"; fi
			;;
	esac
}
main "$@"
