#!/bin/sh

${ISH_CTX_SCRIPT}_os_system() { uname -o }
${ISH_CTX_SCRIPT}_os_kernel() { uname -s }
${ISH_CTX_SCRIPT}_os_machine() { uname -m }
${ISH_CTX_SCRIPT}_os_processor() { uname -p }

${ISH_CTX_SCRIPT}_os_release() { uname -r }
${ISH_CTX_SCRIPT}_os_version() { uname -v }
${ISH_CTX_SCRIPT}_os_hostname() { uname -n }
${ISH_CTX_SCRIPT}_os_username() { whoami }

