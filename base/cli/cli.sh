#!/bin/sh

${ISH_CTX_SCRIPT}_shell() { _meta $0
    name=$(cat /proc/$$/cmdline)
    echo "${name#-}"
}

${ISH_CTX_SCRIPT}_alias() {
    echo "alias" "$1=$2"
    alias $1=$2
}

