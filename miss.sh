#!/bin/sh

[ "$ISH_CONF_PRE" != "" ] || source ./.ish/plug.sh || source ~/.ish/plug.sh
require show.sh
require help.sh

export PATH=${ISH_CONF_TASK}/bin:${PWD}/bin:${PWD}:$PATH
export ctx_mod=${ctx_mod:="gdb,log,ssh,ctx"}
export ctx_pid=${ctx_pid:=var/run/ice.pid}
export ctx_log=${ctx_log:=bin/boot.log}
export ctx_dev=${ctx_dev:="$ISH_CONF_DEV"}
export ctx_pod=${ctx_pod:=""}

ish_miss_ice_sh="bin/ice.sh"
ish_miss_ice_bin="bin/ice.bin"
ish_miss_miss_sh="etc/miss.sh"
ish_miss_main_go="src/main.go"
ish_miss_main_shy="src/main.shy"
ish_miss_init_shy="etc/init.shy"
ish_miss_order_js="usr/publish/order.js"

ish_miss_create_path() {
    local target=$1 && [ -d ${target%/*} ] && return
    [ ${target%/*} != ${target} ] && mkdir -p ${target%/*} || return 0
}
ish_miss_create_file() {
    [ -e $1 ] && return || ish_log_debug -g "create file ${PWD} $1"
    ish_miss_create_path $1 && cat > $1
}
ish_miss_create_link() {
    [ -e $1 ] && return || ish_log_debug -g "create link $1 => $2"
    ish_miss_create_path $1 && ln -s $2 $1
}
ish_miss_help() {
    ish_help_show \
        usage -g "ish_miss_prepare $(ish_show -y repos)" \
                "" "下载代码" \
        usage -r "ish_miss_restart" \
                "" "重启服务" \
                "" "" \
        usage -y "ish_miss_serve $(ish_show -y arg...)" \
                "" "重启服务" \
        usage -g "ish_miss_start $(ish_show -y arg...)" \
                "" "启动服务" \
        usage -r "ish_miss_stop" \
                "" "停止服务" \
        usage -g "ish_miss_log" \
                "" "查看日志" \
                "" "" \
        usage -g "ish_miss_create $(ish_show -y name)" \
                "" "创建项目" \
        usage -g "ish_miss_module $(ish_show -y name)" \
                "" "创建模块" \
        usage -g "ish_miss_docker $(ish_show -y name)" \
                "" "创建容器" \
    end
}

ish_miss_prepare() {
    echo
    for repos in "$@"; do local name=${repos##*/}
        [ "$name" = "$repos" ] && repos=shylinux/$name
        require github.com/$repos
        ish_miss_create_link usr/$name $(require_path $repos)
        cd usr/$name && git pull
        cd -
    done

    ish_miss_create_file $ish_miss_miss_sh <<END
#!/bin/bash
# git &>/dev/null || yum install -y git || apk add git

[ -f ~/.ish/plug.sh ] || [ -f ./.ish/plug.sh ] || git clone https://github.com/shylinux/intshell ./.ish
[ "\$ISH_CONF_PRE" != "" ] || source ./.ish/plug.sh || source ~/.ish/plug.sh
require miss.sh

ish_miss_prepare_compile
ish_miss_prepare_install

ish_miss_prepare_volcanos
ish_miss_prepare learning
ish_miss_prepare_icebergs
# ish_miss_prepare toolkits
# ish_miss_prepare_intshell
# ish_miss_prepare_contexts

# ish_miss_prepare_develop
# ish_miss_prepare_session ${PWD##*/}
END
}
ish_miss_prepare_compile() {
    export ISH_CONF_TASK=${PWD##*/}
    ish_miss_create_file $ish_miss_main_go <<END
package main

import (
	ice "github.com/shylinux/icebergs"
	_ "github.com/shylinux/icebergs/base"
	_ "github.com/shylinux/icebergs/core"
	_ "github.com/shylinux/icebergs/misc"
)

func main() { println(ice.Run()) }
END
    ish_miss_create_file $ish_miss_main_shy <<END
title main
END

    ish_miss_create_file Makefile << END
export GOPROXY=https://goproxy.cn
export GOPRIVATE=github.com
# export CGO_ENABLED=0
all:
	@echo && date
	go build -v -o $ish_miss_ice_bin $ish_miss_main_go && chmod u+x $ish_miss_ice_bin && chmod u+x $ish_miss_ice_sh && ./$ish_miss_ice_sh restart
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
        date && ice.bin \$@ 2>\$ctx_log && echo -e \"\n\nrestarting...\" && break
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
    chmod u+x $ish_miss_ice_sh

    ish_miss_create_file $ish_miss_init_shy <<END
~cli

~aaa

~web

~mdb

~ssh

END

    [ -f go.mod ] || go mod init ${PWD##*/}

    ish_miss_create_file $ish_miss_order_js <<END
Volcanos("onengine", {})
END
}
ish_miss_prepare_volcanos() {
    echo
    require github.com/shylinux/volcanos
    ish_miss_create_link usr/volcanos $(require_path shylinux/volcanos)
    cd usr/volcanos/ && git pull
    cd -
}
ish_miss_prepare_icebergs() {
    echo
    require github.com/shylinux/icebergs
    ish_miss_create_link usr/icebergs $(require_path shylinux/icebergs)
    cd usr/icebergs/ && git pull
    cd -
}
ish_miss_prepare_intshell() {
    echo
    ish_log_require "as ctx $(_color g github.com/shylinux/intshell)"
    ish_miss_create_link usr/intshell $(require_path ../../)
    cd usr/intshell/ && git pull
    cd -
}
ish_miss_prepare_contexts() {
    echo
    ish_log_require "as ctx $(_color g github.com/shylinux/contexts)"
    git pull
    pwd
}
ish_miss_prepare_develop() {
    # sudo yum install -y tmux golang git vim
    echo
}
ish_miss_prepare_session() {
    local name=$1 && [ "$name" = "" ] && name=${PWD##*/}
    ish_log_debug "session: $name"
    if tmux new-session -d -s $name -n shy; then
        tmux split-window -d -p 30 -t $name
        tmux split-window -d -h -t ${name}:shy.2
        local left=2 right=3
        tmux send-key -t ${name}:shy.$right "ish_miss_log" Enter; if [ "$name" = "miss" ]; then
            tmux send-key -t ${name}:shy.$left "ish_miss_serve shy" Enter
        else
            tmux send-key -t ${name}:shy.$left "ish_miss_space dev" Enter
        fi
    fi

    [ "$TMUX" = "" ] && tmux attach -t $name
}

ish_miss_start() {
    while true; do
        # [ -f $ctx_log.old ] && rm $ctx_log.old &>/dev/null
        # [ -f "$ctx_log" ] && mv $ctx_log $ctx_log.old &>/dev/null
        echo -e "\n\nrestarting..." && date && ice.bin $@ 2>$ctx_log && break
    done
}
ish_miss_stop() {
    [ -e $ctx_pid ] && kill -3 `cat $ctx_pid` || echo
}
ish_miss_restart() {
    [ -e $ctx_pid ] && kill -2 `cat $ctx_pid` || echo
}
ish_miss_serve() {
    ish_miss_stop
    ish_miss_start serve $@
}
ish_miss_space() {
    ish_miss_stop
    ish_miss_start space connect $@
}
ish_miss_log() {
    tail -f $ctx_log
}
ish_miss() {
    local cmd=$1 && [ "$1" != "" ] && shift
    ish_web_request $ctx_dev/code/miss/$cmd arg "$*" pwd "$PWD" pid "$$" SHELL "$SHELL" pane "$TMUX_PANE"
}

ish_miss_create() {
    local name=$ISH_CONF_WORK/$1 && [ -d $name ] && cd $name && return
    name=$ISH_CONF_WORK/$(date +%Y%m%d)-$1 && mkdir -p $name && cd $name
    export PATH=${PWD}/bin:${PWD}/bin:$PATH
    ish_miss_prepare
    source etc/miss.sh
}
ish_miss_module() {
    local name=$1 help=$2 && help=${help:=$name}

    ish_miss_create_file src/$name/${name}.go <<END
package $name

import (
	ice "github.com/shylinux/icebergs"
	"github.com/shylinux/icebergs/core/code"
	kit "github.com/shylinux/toolkits"
)

var Index = &ice.Context{Name: "$name", Help: "$help",
	Configs: map[string]*ice.Config{
		"$name": {Name: "$name", Help: "$help", Value: kit.Data()},
	},
	Commands: map[string]*ice.Command{
		ice.CTX_INIT: {Hand: func(m *ice.Message, c *ice.Context, cmd string, arg ...string) {}},
		ice.CTX_EXIT: {Hand: func(m *ice.Message, c *ice.Context, cmd string, arg ...string) {}},

		"$name": {Name: "$name", Help: "$help", Hand: func(m *ice.Message, c *ice.Context, cmd string, arg ...string) {
            m.Echo("hello $name world")
		}},
	},
}

func init() { code.Index.Register(Index, nil) }
END

    ish_miss_create_file src/$name/${name}.shy <<END
chapter "$name"

END
}

