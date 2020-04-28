#!/bin/sh

ish_ctx_code_pprof_list="bin seconds=5 server=$(ish_ctx_tcp_ip|head -n1):26393 port=40000"
ish_ctx_code_pprof() { local prefix=ish_ctx_code_pprof && eval "$ish_list_parse"
    local name=$(ish_ctx_cli_mkfile var/pprof/pprof_$(ish_ctx_date_filename).pd.gz)
    curl -sLo $name "http://$server/debug/pprof/profile?seconds=$seconds"

    local http=$(ish_ctx_tcp_ip|head -n1):$port
    ish_log_debug "$name: $server"
    go tool pprof -http="$http" $bin $name
}
ish_ctx_code_info() {

    echo
    ish_show -green "git log"
    git log -n1 |cat

    echo
    ish_show -green "git status"
    git s

}
return

${ISH_CTX_SCRIPT}_install() { _meta $0
}
${ISH_CTX_SCRIPT}_compile() { _meta $0
}
${ISH_CTX_SCRIPT}_publish() { _meta $0
}
${ISH_CTX_SCRIPT}_upgrade() { _meta $0
}


