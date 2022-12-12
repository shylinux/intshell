#!/bin/bash

ish_dev_vim_prepare() {
    local from=$PWD/usr/intshell/dev/vim to=$HOME/.vim/autoload; mkdir -p $to
    ish_sys_link_create $to/plug.vim $from/plug.vim
    ish_sys_link_create $to/auto.vim $from/auto.vim
		to=$HOME/.vim/syntax; mkdir -p $to
    ish_sys_link_create $to/c.vim $from/c.vim
    ish_sys_link_create $to/go.vim $from/go.vim
    ish_sys_link_create $to/sh.vim $from/sh.vim
    ish_sys_link_create $to/shy.vim $from/shy.vim
    ish_sys_link_create $to/zml.vim $from/zml.vim
    ish_sys_link_create $to/iml.vim $from/iml.vim
    ish_sys_link_create $to/css.vim $from/css.vim
    ish_sys_link_create $to/javascript.vim $from/javascript.vim
    ish_sys_link_create ~/.vimrc $from/vimrc
    vim -c PlugInstall -c exit -c exit
    vim -c GoInstallBinaries -c exit -c exit
}
