#!/bin/bash

ish_ctx_dev_vim_prepare() {
    local from=$PWD/usr/intshell/misc/vim

    mkdir -p ~/.vim/autoload
    ish_miss_create_link ~/.vim/autoload/plug.vim $from/plug.vim
    ish_miss_create_link ~/.vim/autoload/auto.vim $from/auto.vim

    mkdir -p ~/.vim/syntax
    ish_miss_create_link ~/.vim/syntax/go.vim $from/go.vim
    ish_miss_create_link ~/.vim/syntax/sh.vim $from/sh.vim
    ish_miss_create_link ~/.vim/syntax/shy.vim $from/shy.vim
    ish_miss_create_link ~/.vim/syntax/javascript.vim $from/javascript.vim
    ish_miss_create_link ~/.vim/syntax/css.vim $from/css.vim

    ish_miss_create_link ~/.vimrc $from/vimrc
    vim -c PlugInstall -c exit -c exit
    vim -c GoInstallBinaries -c exit -c exit
}
ish_ctx_dev_vim_clear() {
    for path in volcanos learning icebergs toolkits intshell; do
        for file in `find usr/$path/ -name "*swp"`; do
            ish_log_debug "rm $file"; rm $file
        done
    done

    for file in `find ./ -name "*swp"`; do
        ish_log_debug "rm $file"; rm "$file"
    done
}

