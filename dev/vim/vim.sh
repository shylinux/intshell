#!/bin/sh

ish_dev_vim_prepare() {
	local from=$PWD/usr/intshell/dev/vim; ish_sys_link_create ~/.vimrc $from/vimrc
	to=$HOME/.vim/autoload; ish_sys_link_create $to/plug.vim $from/plug.vim; ish_sys_link_create $to/auto.vim $from/auto.vim
	to=$HOME/.vim/syntax; for p in $from/*.vim; do ish_sys_link_create $to/${p##*/} $p; done
}
ish_dev_vim_plug_prepare() {
	vim -c PlugInstall -c exit -c exit; vim -c GoInstallBinaries -c exit -c exit
}
