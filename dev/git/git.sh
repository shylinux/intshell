#!/bin/sh

ish_dev_git_prepare() {
    git config --global alias.s status
    git config --global alias.b branch
    git config --global alias.l "log --oneline --decorate"
    git config --global color.ui always
    git config --global core.autocrlf false
    git config --global core.quotepath false
    git config --global init.defaultBranch master
    git config --global credential.helper store
    git config --global push.default simple
    git config --global pull.ff only
}

