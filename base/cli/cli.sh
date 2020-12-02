#!/bin/sh

ish_ctx_cli_mkfile() {
    local name=$1
    mkdir -p ${name%/*}
    touch $1
    echo $name
}
ish_ctx_cli_jobs() {
    local out=$1 && shift && local err=$1 && shift
    ish_log_debug "pid: $? out: $out err: $err cmd: $@"
    eval "eval $@ >>$out 2>>$err \&"
}

ish_ctx_cli_alias() {
    [ "$#" = "0" ] && alias && return
    [ "$#" = "1" ] && alias $1 && return
    ish_log_alias "-g" "$1" "=>" "$2"
    alias $1="$2"
}
ish_ctx_cli_shell() {
    ps |grep "^\ *$$"|grep -v grep|grep -o "[a-z]*$"
}

ish_ctx_cli_prompt() {
    local name=$(hostname) && name=${name##*-} && name=${name%%\.*}
    case "$(ish_ctx_cli_shell)" in
        bash)
            export PS1="\\!@$name[\\t]\\W\\$ "
            ;;
        zsh)
            export PS1="\\!@$name[\t]\W\$ "
            ;;
    esac
}
ish_ctx_cli_prepare() {
    local rc=".bashrc"; case "$(ish_ctx_cli_shell)" in
        bash) rc=".bashrc";;
        zsh) rc=".zshrc";;
    esac

    [ -d ~/.ish ] || ln -s $PWD/.ish ~/.ish
    grep "source ~/.ish/plug.sh" ~/$rc &>/dev/null || cat >> ~/$rc <<END

if [ -f ~/.ish/plug.sh ] && source ~/.ish/plug.sh; then
    require conf.sh
fi

END
}
