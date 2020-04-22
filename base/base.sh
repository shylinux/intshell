#!/bin/sh

source web/web.sh

ISH_SCRIPT=ish
source date.sh
source os.sh

${ISH_SCRIPT}_host_info() { _meta $0
    echo "hostname: $(hostname)"
    echo "username: $(whoami)"
    echo "pathname: $(pwd)"
}

