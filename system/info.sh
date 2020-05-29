#!/bin/sh

ish_os_system() { uname -o; }
ish_os_kernel() { uname -s; }
ish_os_machine() { uname -m; }
ish_os_processor() { uname -p; }

ish_os_release() { uname -r; }
ish_os_version() { uname -v; }
ish_os_hostname() { uname -n; }
ish_os_username() { whoami; }

