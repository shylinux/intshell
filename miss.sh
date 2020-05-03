#!/bin/sh

ish_miss_ice_sh="bin/ice.sh"
ish_miss_ice_bin="bin/ice.bin"
ish_miss_miss_sh="etc/miss.sh"
ish_miss_main_go="src/main.go"
ish_miss_init_shy="etc/init.shy"
ish_miss_prepare() {
    [ -d ${ish_miss_main_go%/*} ] || mkdir -p ${ish_miss_main_go%/*}
    [ -f $ish_miss_main_go ] || cat >> $ish_miss_main_go <<END
package main

import (
	"github.com/shylinux/icebergs"
	_ "github.com/shylinux/icebergs/base"
	_ "github.com/shylinux/icebergs/core"
	_ "github.com/shylinux/icebergs/misc"
)

func main() { println(ice.Run()) }
END

    [ -f Makefile ] || cat >> Makefile  << END
all:
	@echo && date
	go build -o $ish_miss_ice_bin $ish_miss_main_go && chmod u+x $ish_miss_ice_bin && chmod u+x $ish_miss_ice_sh && ./$ish_miss_ice_sh restart
END

    [ -d ${ish_miss_ice_sh%/*} ] || mkdir -p ${ish_miss_ice_sh%/*}
    [ -f $ish_miss_ice_sh ] || cat >> $ish_miss_ice_sh <<END
#! /bin/sh

export PATH=\${PWD}/bin:\${PWD}:\$PATH
export ctx_log=\${ctx_log:=bin/boot.log}
export ctx_pid=\${ctx_pid:=var/run/ice.pid}
export ctx_mod=\${ctx_mod:=gdb,log,ssh,ctx}

restart() {
    [ -e \$ctx_pid ] && kill -2 \`cat \$ctx_pid\` &>/dev/null || echo
}
start() {
    trap HUP hup && while true; do
        date && ice.bin \$@ 2>\$ctx_log && echo -e \"\n\nrestarting...\" || break
    done
}
stop() {
    [ -e \$ctx_pid ] && kill -3 \`cat \$ctx_pid\` &>/dev/null || echo
}
serve() {
    stop && start \$@
}

cmd=\$1 && [ -n \"\$cmd\" ] && shift || cmd=serve
\$cmd \$*
END

    [ -d ${ish_miss_init_shy%/*} ] || mkdir -p ${ish_miss_init_shy%/*}
    [ -f $ish_miss_init_shy ] || cat >> $ish_miss_init_shy <<END
~cli

~aaa

~ssh

~web
    config serve meta.volcanos.path usr/volcanos

END

    [ -d ${ish_miss_miss_sh%/*} ] || mkdir -p ${ish_miss_miss_sh%/*}
    [ -f $ish_miss_miss_sh ] || cat >> $ish_miss_miss_sh <<END
[ -f ~/.ish/plug.sh ] || [ -f usr/intshell/plug.sh ] || git clone https://github.com/shylinux/intshell usr/intshell
[ "\$ISH_CONF_PRE" != "" ] || source usr/intshell/plug.sh || source ~/.ish/plug.sh
# declare -f ish_help_repos &>/dev/null || require conf.sh

require help.sh
require miss.sh

ish_miss_volcanos_prepare
# ish_miss_icebergs_prepare
# ish_miss_intshell_prepare

END
    [ -f go.mod ] || go mod init ${PWD##*/}
    make
}
ish_miss_volcanos_prepare() {
    require github.com/shylinux/volcanos
    [ -d usr/volcanos ] || ln -s ../.ish/pluged/github.com/shylinux/volcanos usr/volcanos
}
ish_miss_icebergs_prepare() {
    require github.com/shylinux/icebergs
    [ -d usr/icebergs ] || ln -s ../.ish/pluged/github.com/shylinux/icebergs usr/icebergs
}
ish_miss_intshell_prepare() {
    [ -d usr ] || mkdir usr
    [ -d usr/intshell ] || ln -s ../.ish/pluged/github.com/shylinux/intshell usr/intshell
}


ish_miss_create() {
    [ -d $1 ] || mkdir -p $1
    cd $1
    # ish_miss_prepare
}
ish_miss_docker() {
    local name=${PWD##*/}
    # if docker run --name $name --mount type=bind,source=${PWD},target=/root -w /root -dt alpine sh; then
    #     docker exec $name sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
    #     docker exec $name apk add bash curl git
    # fi
    if docker run -p 10000:9020 --name $name --mount type=bind,source=${PWD},target=/root -w /root -dt centos sh; then
        docker exec $name yum install -y make git go
    fi
    docker exec -w /root -it $name bash
}

