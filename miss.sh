#!/bin/sh

export PATH=${PWD}/bin:${PWD}:$PATH
export ctx_pid=${ctx_pid:=var/run/ice.pid}
export ctx_log=${ctx_log:=bin/boot.log}
export ctx_mod=${ctx_mod:="gdb,log,ssh,ctx"}

ish_miss_ice_sh="bin/ice.sh"
ish_miss_ice_bin="bin/ice.bin"
ish_miss_miss_sh="etc/miss.sh"
ish_miss_main_go="src/main.go"
ish_miss_init_shy="etc/init.shy"
ish_miss_order_js="usr/publish/order.js"

ish_miss_create_path() {
    local target=$1 && [ -d ${target%/*} ] && return
    [ ${target%/*} != ${target} ] && mkdir -p ${target%/*} || return 0
}
ish_miss_create_link() {
    [ -e $1 ] && return || ish_log_debug -g "create link $1 => $2"
    ish_miss_create_path $1 && ln -s $2 $1
}
ish_miss_create_file() {
    [ -e $1 ] && return || ish_log_debug -g "create file ${PWD} $1"
    ish_miss_create_path $1 && cat > $1
}

ish_miss_prepare() {
    for name in "$@"; do
        require github.com/shylinux/$name
        ish_miss_create_link usr/$name $(require_path shylinux/$name)
    done

    ish_miss_create_file $ish_miss_miss_sh <<END
[ -f ~/.ish/plug.sh ] || [ -f ./.ish/plug.sh ] || git clone https://github.com/shylinux/intshell ./.ish
[ "\$ISH_CONF_PRE" != "" ] || source ./.ish/plug.sh || source ~/.ish/plug.sh
# declare -f ish_help_repos &>/dev/null || require conf.sh

require help.sh
require miss.sh

ish_miss_prepare_compile
ish_miss_prepare_install

# ish_miss_prepare_volcanos
# ish_miss_prepare_icebergs
# ish_miss_prepare_intshell
END
}
ish_miss_prepare_list() {
    ish_help_show \
        index compile \
        index install \
        index volcanos \
        index icebergs \
        index intshell \
        index toolkits \
        index learning \
    end
}
ish_miss_prepare_compile() {
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
ish_miss_prepare_install() {
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

ish_miss_prepare_volcanos() {
    require github.com/shylinux/volcanos
    ish_miss_create_link usr/volcanos $(require_path shylinux/volcanos)

    ish_miss_create_file $ish_miss_order_js <<END
Volcanos("onengine", {
    remote: function(event, can, msg, pane, cmds, cb) {
        return false
    }
}, [], function(can) {})
END
}
ish_miss_prepare_icebergs() {
    require github.com/shylinux/icebergs
    ish_miss_create_link usr/icebergs  $(require_path shylinux/icebergs)
}
ish_miss_prepare_intshell() {
    ish_miss_create_link usr/intshell $(require_path ../../)
}
ish_miss_prepare_toolkits() {
    require github.com/shylinux/toolkits
    ish_miss_create_link usr/toolkits  $(require_path shylinux/toolkits)
}
ish_miss_prepare_learning() {
    require github.com/shylinux/learning
    ish_miss_create_link usr/learning  $(require_path shylinux/learning)
}

ish_miss_restart() {
    [ -e $ctx_pid ] && kill -2 `cat $ctx_pid` || echo
}
ish_miss_serve() {
    ish_miss_stop
    ish_miss_start serve $@
}
ish_miss_start() {
    while true; do
        date && ice.bin $@ 2>$ctx_log && echo -e "\n\nrestarting..." || break
    done
}
ish_miss_stop() {
    [ -e $ctx_pid ] && kill -3 `cat $ctx_pid` || echo
}
ish_miss_log() {
    tail -f $ctx_log
}

ish_miss_create() {
    local name=$ISH_CONF_WORK/$1 && [ -d $name ] && cd $name && return
    name=$ISH_CONF_WORK/$(date +%Y%m%d)_$1 && mkdir -p $name && cd $name
    ish_miss_prepare && source etc/miss.sh
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

