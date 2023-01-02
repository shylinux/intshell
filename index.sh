#!/bin/sh

export ctx_dev=${ctx_dev:="http://shylinux.com"}

_down_big_file() { # 下载文件 dir url
	[ -f "$1" ] && return || echo "download $ctx_dev/$2"
	echo $1| grep "/" &>/dev/null && mkdir -p ${1%*/*}; if curl -h &>/dev/null; then
		curl -o $1 -fL "$ctx_dev/$2?pod=$ctx_pod"
	else
		wget -O $1 "$ctx_dev/$2?pod=$ctx_pod"
	fi
}
_down_files() { # 下载文件 file...
	for file in "$@"; do _down_file $file publish/${file##*/}; done
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
_down_tars() { # 下载文件 file...
	for file in "$@"; do _down_tar $file publish/$file; done
}
_down_tar() { # 下载文件 file path
	[ -f $1 ] && return; _down_big_file "$@" && tar -xf $1
}

prepare_script() {
	for script in "$@"; do _temp_file $script; done 
}
prepare_require() {
	for script in "$@"; do _temp_file require/$script; done 
}
prepare_package() {
	_down_tars contexts.bin.tar.gz contexts.src.tar.gz
	local back=$PWD; cd ~/; _down_tars contexts.home.tar.gz; cd $back
	export VIM=$PWD/usr/install/vim-vim-12be734/_install/share/vim/vim82/
	export LD_LIBRARY_PATH=$PWD/usr/local/lib

	ish_sys_path_load
	git config --global init.templatedir $PWD/usr/install/git-2.31.1/_install/share/git-core/templates/
	git config --global url."$ctx_dev".insteadOf https://shylinux.com
	git config --global init.defaultBranch master
}
prepare_system() {
	case "$(uname)" in
		Darwin) xcode-select --install 2>/dev/null ;;
		Linux) 
			echo "yum install make git vim tmux"
			if [ `whoami` == root ]; then
				yum install -y make git vim tmux
			else
				sudo yum install -y make git vim tmux
			fi
			;;
	esac
}
prepare_tmux() {
	_down_file etc/tmux.conf dev/tmux/tmux.conf
	_down_file bin/tmux.sh dev/tmux/local.sh
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
			git clone https://shylinux.com/x/intshell $PWD/.ish
			source $PWD/.ish/plug.sh; require conf.sh; require miss.sh
			;;
		project) # 创建项目
			prepare_script plug.sh conf.sh miss.sh; prepare_system
			ish_miss_prepare_compile
			ish_miss_prepare_develop
			ish_miss_prepare_install
			ish_miss_prepare_contexts
			export PATH=${PWD}/bin:$PATH ctx_log=${ctx_log:=/dev/stdout}
			go get shylinux.com/x/ice
			shift && make && ish_miss_serve "$@"
			;;
		source) # 源码安装
			prepare_system
			git clone https://shylinux.com/x/contexts
			shift && cd contexts && source etc/miss.sh "$@"
			;;
		binary) # 应用安装
			export ctx_log=${ctx_log:=/dev/stdout} ctx_dev="https://shylinux.com"
			shift && prepare_ice && bin/ice.bin forever start dev "" "$@"
			;;
		app) # 生产环境
			export ctx_log=${ctx_log:=/dev/stdout}
			shift && prepare_ice && bin/ice.bin forever start dev dev "$@"
			;;
		dev) # 开发环境
			prepare_script plug.sh conf.sh miss.sh
			shift && prepare_package && source etc/miss.sh "$@"
			;;
		cmd) # 命令环境
			prepare_script plug.sh conf.sh miss.sh; ish_sys_dev_init >/dev/null
			shift; [ -n "$*" ] && ish_sys_dev_run "$@"
			;;
		*) # 终端环境
			prepare_script plug.sh conf.sh miss.sh; ish_sys_dev_init
			prepare_require src/main.sh "$@"
			;;
	esac
}

main "$@"
