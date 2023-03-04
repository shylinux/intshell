#!/bin/sh

ish_sys_cli_shell() {
    ps |grep "^\ *$$"|grep -v grep|grep -o "[a-z]*$"
}
ish_sys_cli_title() {
	printf "\e]1;%s\a" "$*"
}
ish_sys_cli_prompt() {
    local name=$(hostname) && name=${name##*-} && name=${name%%\.*}
    case "$(ish_sys_cli_shell)" in
        bash)
            export PS1="\!@$name[\t]\W\$ "
            ;;
        zsh)
            export PS1="\!@$name[\t]\W\$ "
            ;;
        *)
            export PS1="\!@$name[\w]\$ "
        	;;
    esac
}
ish_sys_cli_alias() {
    [ "$#" = "0" ] && alias && return; [ "$#" = "1" ] && alias $1 && return
    ish_log_alias "-g" "$1 <= $2"; alias $1="$2"
}
ish_sys_cli_prepare() {
    local rc=".bashrc"; case "$(ish_sys_cli_shell)" in
        bash) rc=".bashrc";;
        zsh) rc=".zshrc";;
    esac
	[ -f ~/.profile ] || echo "source ~/.bashrc" > ~/.profile
	[ -f ~/.bash_profile ] || echo "source ~/.bashrc" > ~/.bash_profile
    [ -d ~/.ish ] || [ "$PWD" = "$HOME" ] || ln -s $PWD/.ish $HOME/.ish
    grep "require conf.sh" ~/$rc &>/dev/null || cat >> ~/$rc <<END
if [ -f ~/.ish/plug.sh ] && source ~/.ish/plug.sh; then
    require conf.sh; require miss.sh
fi
[ -f ~/.bash_local.sh ] && source ~/.bash_local.sh
END
}
