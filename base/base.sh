#!/bin/sh

require web/web.sh
ISH_SCRIPT=ish

require cli/date.sh
require cli/os.sh

${ISH_SCRIPT}_host_info() { _meta $0
    echo "hostname: $(hostname)"
    echo "username: $(whoami)"
    echo "pathname: $(pwd)"
}

