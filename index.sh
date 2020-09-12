#!/bin/sh

ctx_dev=${ctx_dev:="https://shylinux.com"}
ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/plug.sh >$ctx_temp; source $ctx_temp
ctx_temp=$(mktemp); curl -sL $ctx_dev/intshell/conf.sh >$ctx_temp; source $ctx_temp

