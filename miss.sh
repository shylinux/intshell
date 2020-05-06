#!/bin/sh

ish_miss_ice_sh="bin/ice.sh"
ish_miss_ice_bin="bin/ice.bin"
ish_miss_miss_sh="etc/miss.sh"
ish_miss_main_go="src/main.go"
ish_miss_init_shy="etc/init.shy"
ish_miss_order_js="usr/publish/order.js"

ish_miss_create_path() {
    local target=$1 && [ -d ${target%/*} ] && return
    [ -d ${target%/*} != ${target} ] && mkdir -p ${target%/*}
}
ish_miss_create_link() {
    [ -e $1 ] && return || ish_log_debug "create link $1 => $2"
    ish_miss_create_path && ln -s $2 $1
}
ish_miss_create_file() {
    [ -e $1 ] && return || ish_log_debug "create file $1"
    ish_miss_create_path && cat > $1
}

ish_miss_prepare() {
    ish_miss_create_file $ish_miss_miss_sh <<END
[ -f ~/.ish/plug.sh ] || [ -f ./.ish/plug.sh ] || git clone https://github.com/shylinux/intshell ./.ish
[ "\$ISH_CONF_PRE" != "" ] || source ./.ish/plug.sh || source ~/.ish/plug.sh
# declare -f ish_help_repos &>/dev/null || require conf.sh

require help.sh
require miss.sh

ish_miss_volcanos_prepare
# ish_miss_icebergs_prepare
# ish_miss_intshell_prepare
END
}
ish_miss_compile_prepare() {
    ish_miss_create_file $ish_miss_main_go <<END
package main

import (
	"github.com/shylinux/icebergs"
	_ "github.com/shylinux/icebergs/base"
	_ "github.com/shylinux/icebergs/core"
	_ "github.com/shylinux/icebergs/misc"
)

func main() { println(ice.Run()) }
END

    ish_miss_create_file Makefile << END
all:
	@echo && date
	go build -o $ish_miss_ice_bin $ish_miss_main_go && chmod u+x $ish_miss_ice_bin && chmod u+x $ish_miss_ice_sh && ./$ish_miss_ice_sh restart
END
}
ish_miss_install_prepare() {
    ish_miss_create_file $ish_miss_ice_sh <<END
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

    ish_miss_create_file $ish_miss_init_shy <<END
~cli

~aaa

~ssh

~web
    config serve meta.volcanos.path usr/volcanos

END

    [ -f go.mod ] || go mod init ${PWD##*/}
}

ish_miss_volcanos_prepare() {
    require github.com/shylinux/volcanos
    ish_miss_create_link usr/volcanos ../.ish/pluged/github.com/shylinux/volcanos

    ish_miss_create_file $ish_miss_order_js <<END
Volcanos("onengine", {
    remote: function(event, can, msg, pane, cmds, cb) {
        return false
    }
}, [], function(can) {})
END
}
ish_miss_icebergs_prepare() {
    require github.com/shylinux/icebergs
    ish_miss_create_link usr/icebergs ../.ish/pluged/github.com/shylinux/icebergs
}
ish_miss_intshell_prepare() {
    ish_miss_create_link usr/intshell ../.ish/
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

