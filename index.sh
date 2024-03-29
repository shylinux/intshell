#!/bin/sh

export ctx_dev=${ctx_dev:="https://shylinux.com"}

_down_big_file() {
	[ -f "$1" ] && return; echo "download $ctx_dev/$2"
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
			if cat /etc/os-release|grep alpine &>/dev/null; then
				sed -i 's/dl-cdn.alpinelinux.org/mirrors.tencent.com/g' /etc/apk/repositories && apk update
				TZ=Asia/Shanghai; apk add tzdata && cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
				git version &>/dev/null || apk add git
				go version &>/dev/null || apk add go
				return
			fi
			if cat /etc/os-release|grep "CentOS-8"&>/dev/null; then
				minorver=8.5.2111; sed -e "s|^mirrorlist=|#mirrorlist=|g" -e "s|^#baseurl=http://mirror.centos.org/\$contentdir/\$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/$minorver|g" -i.bak /etc/yum.repos.d/CentOS-*.repo && yum update -y
				git version &>/dev/null || yum install -y git
				go version &>/dev/null || yum install -y go
				return
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
	local file=bin/ice.bin; [ -e bin ] || mkdir bin
	_down_big_file $file publish/$bin && chmod u+x $file; [ -f $file ]
}
prepare_reload() {
	local temp=$(mktemp); if curl -V &>/dev/null; then curl -o $temp -fsSL $ctx_dev; else wget -O $temp -q $ctx_dev; fi && source $temp $ctx_mod 
}
main() {
	case "$1" in
		binary)
			shift && prepare_ice && bin/ice.bin forever start dev "" "$@"
			;;
		source)
			prepare_system && git clone https://shylinux.com/x/contexts
			shift && cd contexts && source etc/miss.sh "$@"
			;;
		intshell)
			[ -f $PWD/.ish/plug.sh ] && source $PWD/.ish/plug.sh && return
			[ -f $HOME/.ish/plug.sh ] && source $HOME/.ish/plug.sh && return
			prepare_system; git clone https://shylinux.com/x/intshell $PWD/.ish
			source $PWD/.ish/plug.sh; require conf.sh; require miss.sh
			;;
		*)
			prepare_script; if echo $1|grep ".sh$" &>/dev/null; then require "$@"; else require src/main.sh "$@"; fi
			;;
	esac
}
main "$@"
