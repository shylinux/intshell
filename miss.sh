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
ish_miss_init_shy="etc/init.shy"
ish_miss_order_js="usr/publish/order.js"

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
    for repos in "$@"; do local name=${repos##*/}
        [ "$name" = "$repos" ] && repos=shylinux/$name
        require github.com/$repos
        ish_miss_create_link usr/$name $(require_path $repos)
    done

    ish_miss_create_file $ish_miss_miss_sh <<END
#!/bin/bash
git &>/dev/null || apk add git || yum install -y git

[ -f ~/.ish/plug.sh ] || [ -f ./.ish/plug.sh ] || git clone https://github.com/shylinux/intshell ./.ish
[ "\$ISH_CONF_PRE" != "" ] || source ./.ish/plug.sh || source ~/.ish/plug.sh

require show.sh
require help.sh
require miss.sh

ish_miss_prepare_compile
ish_miss_prepare_install
# ish_miss_prepare_develop
# ish_miss_prepare_session ${PWD##*/}

ish_miss_prepare learning
ish_miss_prepare_volcanos
# ish_miss_prepare_icebergs
# ish_miss_prepare_intshell

END
}
ish_miss_prepare_help() {
    ish_help_show \
        usage -g "ish_miss_prepare_compile" \
                "" "生成源码" \
        usage -r "ish_miss_prepare_install" \
                "" "生成脚本" \
                "" "" \
        usage -g "ish_miss_prepare_volcanos" \
                "" "前端框架" \
        usage -y "ish_miss_prepare_icebergs" \
                "" "后端框架" \
        usage -r "ish_miss_prepare_intshell" \
                "" "终端框架" \
                "" "" \
        usage -g "ish_miss_prepare_toolkits" \
                "" "工具代码" \
        usage -g "ish_miss_prepare_learning" \
                "" "知识体系" \
    end
}
ish_miss_prepare_compile() {
    if ! go version; then
        curl -o go.tar.gz https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
        tar xvf go.tar.gz -C /usr/local
    fi

    export GOPROXY=https://goproxy.cn
    export GORPIVATE=github.com
    export GOROOT=/usr/local/go
    export PATH=/usr/local/go/bin:$PATH

    export ISH_CONF_TASK=${PWD##*/}
    ish_miss_create_file $ish_miss_main_go <<END
package main

import (
	"github.com/shylinux/icebergs"
	_ "github.com/shylinux/icebergs/base"
	_ "github.com/shylinux/icebergs/core"
	_ "github.com/shylinux/icebergs/misc"
    // add local module
    // _ "$ISH_CONF_TASK/src/demo"
)

func main() { println(ice.Run()) }
END

    apk add make || yum install -y make
    ish_miss_create_file Makefile << END
export GOPROXY=https://goproxy.cn
export GORPIVATE=github.com
export CGO_ENABLED=0
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
ish_miss_prepare_develop() {
    apk add wget || yum install -y wget
    mkdir -p .vim/autoload/; [ -f .vim/autoload/plug.vim ] || wget $ctx_dev/publish/plug.vim -qO .vim/autoload/plug.vim
    [ -f .vimrc ] || wget $ctx_dev/publish/vimrc -qO .vimrc

    apk add vim || yum install -y vim
    vim -c "PlugInstall | qa"
    vim -c "GoInstallBinaries"
}
ish_miss_prepare_session() {
    local name=$1 && [ "$name" = "" ] && name=${PWD##*/}
    ish_log_debug "session: $name"
    if tmux new-session -d -s $name -n shy; then
        tmux split-window -d -p 30 -t $name
        tmux split-window -d -h -t ${name}:shy.2
        tmux send-key -t ${name}:shy.2 ish_miss_start Enter
        tmux send-key -t ${name}:shy.3 ish_miss_log Enter
    fi

    [ "$TMUX" = "" ] && tmux attach -t $name
}
ish_miss_prepare_volcanos() {
    require github.com/shylinux/volcanos
    ish_miss_create_link usr/volcanos $(require_path shylinux/volcanos)
}
ish_miss_prepare_icebergs() {
    require github.com/shylinux/icebergs
    ish_miss_create_link usr/icebergs $(require_path shylinux/icebergs)
}
ish_miss_prepare_intshell() {
    ish_miss_create_link usr/intshell $(require_path ../../)
}

ish_miss_start() {
    while true; do
        rm $ctx_log.old
        mv $ctx_log $ctx_log.old
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
}
ish_miss_module() {
    local name=$1 help=$2 && help=${help:=$name}

    ish_miss_create_file src/$name/${name}.sh <<END
ish_miss_$name() {
    echo "hello $name world"
}

END

    ish_miss_create_file src/$name/${name}.go <<END
package $name

import (
	"github.com/shylinux/icebergs"
	"github.com/shylinux/icebergs/core/code"
	"github.com/shylinux/toolkits"
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

    ish_miss_create_link usr/publish/${name}.js ../../src/$name/${name}.js
    ish_miss_create_file src/$name/${name}.js <<END
Volcanos("onimport", {help: "导入数据", list: [],
    _init: function(can, msg, list, cb, target) {
        can.onappend.table(can, target, "table", msg)
        can.onappend.board(can, target, "board", msg)
        return typeof cb == "function" && cb(msg)
    },
})
Volcanos("onaction", {help: "交互操作", list: [],
    _init: function(can, msg, list, cb, target) {},
})
Volcanos("onexport", {help: "导出数据", list: [],
    _init: function(can, msg, list, cb, target) {},
})
END

    ish_miss_create_file src/$name/${name}.shy <<END
chapter "$name"

END
}

ish_miss_local() {
    docker exec -it ${PWD##*/} sh
}
ish_miss_centos() {
    docker run $(ish_miss_docker_args) -it centos sh
}
ish_miss_alpine() {
    docker run $(ish_miss_docker_args) -it alpine sh
}
ish_miss_docker() {
    docker run $(ish_miss_docker_args) -it shylinux/contexts "$@"
}
ish_miss_docker_args() {
    echo "--mount type=bind,source=${PWD},target=/root -w /root -e ctx_dev=$ctx_dev -e ctx_user=$USER"
}
ish_miss_docker_image() {
    local name=contexts && [ "$1" != "" ] && name=$1

    rm -rf usr/docker/meta
    mkdir -p usr/docker/meta/volcanos
    cp -r usr/volcanos/* usr/docker/meta/volcanos/
    cp -r usr/demo usr/docker/meta

    local target=/usr/local/bin
    ish_miss_create_file usr/docker/$name <<END
# FROM busybox

FROM alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN mkdir /root/src /root/etc /root/bin /root/var /root/usr
ADD $ctx_dev/publish/ice.sh /usr/local/bin/ice.sh
ADD $ctx_dev/publish/ice.linux.amd64 /usr/local/bin/ice.bin
ADD $ctx_dev/publish/init.shy /root/etc/init.shy
RUN chmod u+x /usr/local/bin/*

RUN mkdir -p /root/usr/publish
RUN mkdir -p /root/usr/volcanos
ADD $ctx_dev/publish/order.js /root/usr/publish/order.js
COPY meta/volcanos /root/usr/volcanos
COPY meta/demo /root/usr/demo

ENV ctx_dev $ctx_dev
ENV ctx_user root
WORKDIR /root
EXPOSE 9020
CMD /usr/local/bin/ice.sh start serve dev
END

    docker build usr/docker/ -f usr/docker/$name -t $name
}

