# shell plugin manager

## Abort

plug.sh allows you to...

- keep track of and configure your plugins right in the .ish/pluged/
- install configured plugins (a.k.a. scripts/bundle)
- update configured plugins
- search by name all available Vim scripts
- clean unused plugins up

plug.sh automatically...

- clone the repos if the plugins don't exists
- load the script if the plugins don't source
- manages the runtime path of your installed scripts
- regenerates help tags after installing and updating

## Quick Start
1. Set up plug.sh

```sh
git clone https://github.com/shylinux/shell.git ~/.ish
```

2. Configure Plugins:
Put this at the bottom of your .bashrc to use plug.sh.
```sh
source ~/.ish/plug.sh

ish github.com/shylinux/shell
ish github.com/xxx/xxx
ish github.com/xxx/xxx
```

