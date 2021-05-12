#!/bin/sh

ish_sys_web_word() {
    echo "$*"|sed "s/\ /%20/g"|sed "s/|/%7C/g"|sed "s/\;/%3B/g"|sed "s/\[/%5B/g"|sed "s/\]/%5D/g"
}
ish_sys_web_request() {
    local url="$1" && shift && while [ "$#" -gt "1" ]; do
        echo "-F" "$1=$(ish_sys_web_word $2)" && shift 2
    done |xargs curl -sL $url
}
