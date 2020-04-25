#!/bin/sh

ish_ctx_os_system() { uname -o; }
ish_ctx_os_kernel() { uname -s; }
ish_ctx_os_machine() { uname -m; }
ish_ctx_os_processor() { uname -p; }

ish_ctx_os_release() { uname -r; }
ish_ctx_os_version() { uname -v; }
ish_ctx_os_hostname() { uname -n; }
ish_ctx_os_username() { whoami; }

