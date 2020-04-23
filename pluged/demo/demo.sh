#!/bin/sh

ish set repos "github.com/xxx/demo"
ish set owner "xxx@gmail.com"
ish set product "plugin demo"
ish set version "v0.0.1"

${ISH_CTX_SCRIPT}_help() { ish mod $0
    echo "repos: $(ish get repos)"
    echo "owner: $(ish get owner)"
    echo "product: $(ish get product)"
    echo "version: $(ish get version)"
}
${ISH_CTX_SCRIPT}_test() {
}
${ISH_CTX_SCRIPT}_init() {
}
${ISH_CTX_SCRIPT}_exit() {
}
