#!/bin/sh

ISH_SCRIPT=ish_web

script def dev "http://localhost:9020"

${ISH_SCRIPT}_word() {
    echo "$*"|sed "s/\ /%20/g"|sed "s/|/%7C/g"|sed "s/\;/%3B/g"|sed "s/\[/%5B/g"|sed "s/\]/%5D/g"
}
${ISH_SCRIPT}_line() {
    echo "$*"|sed -e 's/\"/\\\"/g' -e 's/\n/\\n/g'
}
${ISH_SCRIPT}_request() { _meta $0
    local p=$(script get dev)$1 && shift
    ish_log "request $p $@"
    curl $p "$@" -F "pwd=$(pwd)" -F "sid=$(script get sid)"
}

${ISH_SCRIPT}_help() { _meta $0
    script request /code/zsh/help
}
${ISH_SCRIPT}_info() { _meta $0
    echo "dev: $(script get dev)"
    echo "sid: $(script get sid)"
}

${ISH_SCRIPT}_login_help() { _meta $0
    echo "usage: ${ISH_SCRIPT} host"
}
${ISH_SCRIPT}_login() { _meta $0
    [ "$(script get sid)" != "" ] && script info && return
    [ "$1" = "" ] && script login_help && return || script set dev $1
    script set sid $(script request /code/zsh/login 2>/dev/null)
    script info
}
${ISH_SCRIPT}_upload_help() { _meta $0
    echo "usage: ${ISH_SCRIPT} file"
}
${ISH_SCRIPT}_upload() { _meta $0
    [ "$1" = "" ] && script upload_help && return
    script request /code/zsh/upload -F "upload=@$1"
}
${ISH_SCRIPT}_download_help() { _meta $0
    echo "usage: ${ISH_SCRIPT} [file]"
}
${ISH_SCRIPT}_download() { _meta $0
    script request /code/zsh/download -F "cmds=$(script word "$*")"
}
${ISH_SCRIPT}_logout() { _meta $0
    script request /code/zsh/logout
    script set sid ""
}

${ISH_SCRIPT}_init() { _meta $0
    [ "$(script get sid)" = "" ] && script login $(script get dev)
}
${ISH_SCRIPT}_exit() { _meta $0
    [ "$(script get sid)" = "" ] || script logout
}
${ISH_SCRIPT}_init
