#!/bin/sh

ish def dev "http://localhost:9020"

${ISH_CTX_SCRIPT}_word() {
    echo "$*"|sed "s/\ /%20/g"|sed "s/|/%7C/g"|sed "s/\;/%3B/g"|sed "s/\[/%5B/g"|sed "s/\]/%5D/g"
}
${ISH_CTX_SCRIPT}_line() {
    echo "$*"|sed -e 's/\"/\\\"/g' -e 's/\n/\\n/g'
}
${ISH_CTX_SCRIPT}_request() { _meta $0
    local p=$(ish get dev)$1 && shift
    ish_log "request $p $@"
    curl $p "$@" -F "pwd=$(pwd)" -F "sid=$(ish get sid)"
}

${ISH_CTX_SCRIPT}_help() { _meta $0
    ish run request /code/zsh/help
}
${ISH_CTX_SCRIPT}_ice() { _meta $0
    ish run request /code/zsh/ice -F "sub=$(ish run word "$*")"
}
${ISH_CTX_SCRIPT}_info() { _meta $0
    echo "dev: $(ish get dev)"
    echo "sid: $(ish get sid)"
}

${ISH_CTX_SCRIPT}_login_help() { _meta $0
    echo "usage: ${ISH_CTX_SCRIPT} host"
}
${ISH_CTX_SCRIPT}_login() { _meta $0
    [ "$(ish get sid)" != "" ] && ish run info && return
    [ "$1" = "" ] && ish run login_help && return || ish set dev $1
    ish set sid $(ish run request /code/zsh/login 2>/dev/null)
    ish run info
}
${ISH_CTX_SCRIPT}_upload_help() { _meta $0
    echo "usage: ${ISH_CTX_SCRIPT} file"
}
${ISH_CTX_SCRIPT}_upload() { _meta $0
    [ "$1" = "" ] && ish run upload_help && return
    ish run request /code/zsh/upload -F "upload=@$1"
}
${ISH_CTX_SCRIPT}_download_help() { _meta $0
    echo "usage: ${ISH_CTX_SCRIPT} [file]"
}
${ISH_CTX_SCRIPT}_download() { _meta $0
    ish run request /code/zsh/download -F "cmds=$(ish run word "$*")"
}
${ISH_CTX_SCRIPT}_logout() { _meta $0
    ish run request /code/zsh/logout
    ish set sid ""
}

${ISH_CTX_SCRIPT}_init() { _meta $0
    [ "$(ish get sid)" = "" ] && ish run login $(ish get dev)
}
${ISH_CTX_SCRIPT}_exit() { _meta $0
    [ "$(ish get sid)" = "" ] || ish run logout
}
${ISH_CTX_SCRIPT}_init
