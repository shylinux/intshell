#!/bin/sh

${ISH_SCRIPT}_os_system() { uname -o }
${ISH_SCRIPT}_os_kernel() { uname -s }
${ISH_SCRIPT}_os_machine() { uname -m }
${ISH_SCRIPT}_os_release() { uname -r }
${ISH_SCRIPT}_os_version() { uname -v }
${ISH_SCRIPT}_os_hostname() { uname -n }


