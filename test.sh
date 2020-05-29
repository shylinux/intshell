#!/bin/sh

ish_test_ok=0 ish_test_err=0 ish_test_all=0
ish_test_clear() { ish_test_ok=0 ish_test_err=0 ish_test_all=0; }
ish_test_help() {
    ish_help_render \
        usage -green "ish_test prepare result expect" \
        "" "prepare: cmd pre run" \
        "" "result: cmd make result" \
        "" "expect: cmd make expect result"
}
require_test() {
    ISH_CTX_MODULE=ish_ctx ISH_CTX_SCRIPT=ish_ctx ish_test "require base/cli/os.sh"\
        "ish_os_kernel" "uname -s"

    ish_test "require github.com/shylinux/intshell base/cli/date.sh" \
        "ish_ctx_date_hour" "date +%H"

    ish_test "require github.com/shylinux/intshell" \
        "ish_os_kernel" "uname -s"
}
ish_test() {
    if [ "$#" -eq 0 ]; then
        ish_test_clear
        require_test

        ish_test "" "ish github.com/shylinux/intshell/system.info.os_os_kernel" "uname -s"
        ish_test "" "ish system.info_os_kernel" "uname -s"
        ish_test "" "ish os_kernel" "uname -s"
        return
    fi

    [ -n "$1" ] && _eval "$1"; ish_test_result=$(_eval "$2") ish_test_expect=$(_eval "$3")

    if let ish_test_all=$ish_test_all+1 && [ "$ish_test_result" = "$ish_test_expect" ]; then
        let ish_test_ok=$ish_test_ok+1
        ish_log_test -green "success $ish_test_ok/$ish_test_all/$ish_test_err $1"
        ish_log_test "result: \$($2) -> \"$ish_test_result\""
    else
        let ish_test_err=$ish_test_err+1
        ish_log_test -red "failure $ish_test_err/$ish_test_all/$ish_test_ok $1"
        ish_log_test "result: \$($2) -> \"$ish_test_result\""
        ish_log_test "expect: \$($3) -> \"$ish_test_expect\""
    fi
}

