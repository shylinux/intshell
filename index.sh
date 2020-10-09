#!/bin/sh

ctx_dev=${ctx_dev:="https://shylinux.com"}; case "$1" in
    dev)
        git clone https://github.com/shylinux/contexts && cd contexts && source etc/miss.sh
        ;;
    ice)
        mkdir bin &>/dev/null; curl -sL $ctx_dev/publish/ice.sh > bin/ice.sh && chmod u+x bin/ice.sh && bin/ice.sh serve serve start dev dev
        ;;
    *)
        ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/plug.sh >$ctx_temp; source $ctx_temp
        ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/conf.sh >$ctx_temp; source $ctx_temp
esac
