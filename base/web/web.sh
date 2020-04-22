#!/bin/sh

ISH_SCRIPT=ish_web

${ISH_SCRIPT}_help() { _meta $0
    curl $(script get dev "http://localhost:9020")/code/zsh/help
}
${ISH_SCRIPT}_login() { _meta $0
    script set dev $1
    local sid=$(curl $(script get dev "http://localhost:9020")/code/zsh/login)
    script set sid $sid
}
${ISH_SCRIPT}_upload() { _meta $0
    curl $(script get dev "http://localhost:9020")/code/zsh/upload
}
${ISH_SCRIPT}_download() { _meta $0
    curl $(script get dev "http://localhost:9020")/code/zsh/download
}
${ISH_SCRIPT}_info() { _meta $0
    echo $ISH_SCRIPT
    echo "dev: $(script get dev)"
    echo "sid: $(script get sid)"
}
${ISH_SCRIPT}_logout() { _meta $0
}
