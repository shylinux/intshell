#!/bin/sh

ish_sys_file_size() {
    local size=`ls -s $1 2>/dev/null| grep -o "[0-9]*"|head -n1`
    [ "$size" = "" ] && size=0; echo $size
}

