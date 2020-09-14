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
    mkdir -p ~/.vim/autoload
    ish_miss_create_link ~/.vim/autoload/plug.vim $PWD/usr/intshell/misc/vim/plug.vim
    ish_miss_create_link ~/.vim/autoload/auto.vim $PWD/usr/intshell/misc/vim/auto.vim
    ish_miss_create_link ~/.vimrc $PWD/usr/intshell/misc/vim/vimrc

    mkdir -p ~/.vim/syntax
    ish_miss_create_link ~/.vim/syntax/sh.vim $PWD/etc/conf/sh.vim
    ish_miss_create_link ~/.vim/syntax/shy.vim $PWD/etc/conf/shy.vim
    ish_miss_create_link ~/.vim/syntax/go.vim $PWD/etc/conf/go.vim
    ish_miss_create_link ~/.vim/syntax/javascript.vim $PWD/etc/conf/javascript.vim
}
