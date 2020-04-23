#!/bin/sh

ish_test_ok=0 ish_test_err=0 ish_test_all=0
ish_test_clear() {
    ish_test_ok=0 ish_test_err=0 ish_test_all=0
}
ish_test() {
    if [ "$2" != "" ]; then [ -z "$1" ] || _eval "$1" 
        ish_test_result=$(_eval "$2") ish_test_expect=$(_eval "$3")
        let ish_test_all=$ish_test_all+1 && [ "$ish_test_result" = "$ish_test_expect" ] && let ish_test_ok=$ish_test_ok+1 && \
            ish_log_test "$(_color green success $ish_test_ok/$ish_test_all/$ish_test_err $1) \nresult: \$($2) -> \"$ish_test_result\"\n" && return
        let ish_test_err=$ish_test_err+1
            ish_log_test $(_color red failure $ish_test_err/$ish_test_all/$ish_test_ok $1 ) "\nresult: \$($2) -> \"$ish_test_result\" \nexpect: \$($3) -> \"$ish_test_expect\"\n" && return
    fi

    require_test

    ish_test "" "ish github.com/shylinux/shell/base.cli.os_os_system" "uname -o"
    ish_test "" "ish base.cli.os_os_system" "uname -o"
    ish_test "" "ish os_system" "uname -o"
}

