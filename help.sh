#!/bin/sh

script set repos "github.com/shylinux/shell"
script set owner "shylinuxc@gmail.com"
script set product "plugin manager"
script set version "v0.0.1"

${ISH_SCRIPT}_info() { _meta $0
    echo "repos: $(script get repos)"
    echo "owner: $(script get owner)"
    echo "product: $(script get product)"
    echo "version: $(script get version)"
}
${ISH_SCRIPT}_help() { _meta $0
    echo "usage: ish mod/file.fun arg..."
}
${ISH_SCRIPT}_test() { _meta $0
    pwd
    echo $*
}

