#!/bin/sh

ish_ctx_dev_tmux_pwd() {
    curl -so etc/tmux.conf --create-dirs $ctx_dev/intshell/misc/tmux/tmux.conf

    mkdir -p bin
    cat >bin/send-intshell.sh <<END
#!/bin/sh

tmux send-key "export ctx_dev=http://172.30.8.42:9020 ctx_temp=\\\$(mktemp); curl -sL $ctx_dev >\\\$ctx_temp; source \\\$ctx_temp " Enter
END
}
ish_ctx_dev_tmux_home() {
    curl -so ~/.tmux.conf --create-dirs $ctx_dev/intshell/misc/tmux/tmux.conf
}

ish_ctx_dev_tmux_prepare() {
    ish_miss_create_link ~/.tmux.conf $PWD/usr/intshell/misc/tmux/tmux.conf
}
