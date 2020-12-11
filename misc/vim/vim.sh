#! /bin/sh

ish_ctx_dev_vim_pwd() {
    curl -so ~/.vim/autoload/plug.vim --create-dirs $ctx_dev/intshell/misc/vim/plug.vim
    curl -so ~/.vim/autoload/auto.vim --create-dirs $ctx_dev/intshell/misc/vim/auto.vim
    curl -so etc/vimrc --create-dirs $ctx_dev/intshell/misc/vim/vimrc
}
ish_ctx_dev_vim_home() {
    curl -so ~/.vim/autoload/plug.vim --create-dirs $ctx_dev/intshell/misc/vim/plug.vim
    curl -so ~/.vim/autoload/auto.vim --create-dirs $ctx_dev/intshell/misc/vim/auto.vim
    curl -so ~/.vimrc $ctx_dev/intshell/misc/vim/vimrc
}

ish_ctx_dev_vim_prepare() {
    local from=$PWD/usr/intshell/misc/vim

    mkdir -p ~/.vim/autoload
    ish_miss_create_link ~/.vim/autoload/plug.vim $from/plug.vim
    ish_miss_create_link ~/.vim/autoload/auto.vim $from/auto.vim

    mkdir -p ~/.vim/syntax
    ish_miss_create_link ~/.vim/syntax/javascript.vim $from/javascript.vim
    ish_miss_create_link ~/.vim/syntax/go.vim $from/go.vim
    ish_miss_create_link ~/.vim/syntax/shy.vim $from/shy.vim
    ish_miss_create_link ~/.vim/syntax/sh.vim $from/sh.vim

    ish_miss_create_link ~/.vimrc $from/vimrc
    vim -c PlugInstall -c exit -c exit
}
