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
### 1. Set up plug.sh

```sh
git clone https://github.com/shylinux/shell.git ~/.ish
```

### 2. Configure Plugins:
Put this at the bottom of your .bashrc to use plug.sh.
```sh
if [ -f ~/.ish/plug.sh ]; then
   source ~/.ish/plug.sh

   require github.com/shylinux/shell help.sh
   # ... add other plugins
fi

```

### 3. Use Plugins:
**use by auto load**
```sh
$ ish github.com/shylinux/shell/help.info
repos: github.com/shylinux/shell
owner: shylinuxc@gmail.com
product: plugin manager
version: v0.0.1

```

**use by manual load**
```sh
$ require github.com/shylinux/shell help.sh
```

after load help.sh, you call all the function directly
```sh
$ ish_github_com_shylinux_shell__help_info
repos: github.com/shylinux/shell
owner: shylinuxc@gmail.com
product: plugin manager
version: v0.0.1

$ ish_github_com_shylinux_shell__help_help
usage: ish mod/file.fun arg...

```

## Create Plugins:
### add plugin
if the plugin named *demo*
add the code to the file $ISH_PATH/demo/demo.sh
```sh
script set repos "github.com/xxx/xxx"
script set owner "xxx@gmail.com"
script set product "plugin demo"
script set version "v0.0.1"

${ISH_SCRIPT}_info() { _meta $0
    echo "repos: $(script get repos)"
    echo "owner: $(script get owner)"
    echo "product: $(script get product)"
    echo "version: $(script get version)"
}
${ISH_SCRIPT}_help() { _meta $0
    echo "usage: ish mod/file.fun arg..."
}
```

### use plugin
use the new plugin
```sh
$ ish demo/demo.info
repos: github.com/xxx/demo
owner: xxx@gmail.com
product: plugin demo
version: v0.0.1
```

### share plugin
if you create git repos, and push it to the github, use by long name
```sh
$ ish github.com/xxx/demo/demo.info
repos: github.com/xxx/xxx
owner: xxx@gmail.com
product: plugin demo
version: v0.0.1
```
