#! /bin/sh

ish_ctx_dev_git_home() {
    git config --global alias.s status
    git config --global alias.b branch
    git config --global credential.helper store
}
