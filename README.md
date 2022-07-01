# intshell
INTSHELL alias for in the shell, a plugin manager system

## Abort

INTSHELL allows you to...

- keep track of and configure your plugins right in the .ish/pluged/
- install configured plugins (a.k.a. scripts/bundle)
- update configured plugins
- search by name all available scripts
- clean unused plugins up

INTSHELL automatically...

- clone the repos if the plugins don't exists
- load the script if the plugins don't source
- manages the runtime path of your installed scripts
- regenerates help tags after installing and updating

## Quick Start
### 1. Download INTSHELL

```sh
git clone https://shylinux.com/x/intshell.git ~/.ish
```

### 2. Configure Plugins:
Put this at the bottom of your .bashrc to use INTSHELL
```sh
if [ -f ~/.ish/plug.sh ] && source ~/.ish/plug.sh; then
    require conf.sh
    require miss.sh
   # ... add other plugins
fi

```

### 3. Use Plugins:
**use by manual load**
```sh
$ require shylinux.com/x/intshell sys/cli/date.sh
```

after load date.sh, you call all the function directly
```sh
$ ish_sys_date
2022-07-01 15:50:30
```
