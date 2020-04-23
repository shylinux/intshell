# shell plugin manager

## Abort

plug.sh allows you to...

- keep track of and configure your plugins right in the .ish/pluged/
- install configured plugins (a.k.a. scripts/bundle)
- update configured plugins
- search by name all available scripts
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
if [ -f ~/.ish/plug.sh ] && source ~/.ish/plug.sh; then
    require conf.sh
    require as miss github.com/shylinux/shell misc/miss/miss.sh
   # ... add other plugins
fi

```

### 3. Use Plugins:
**use by auto load**
```sh
$ ish github.com/shylinux/shell/base.cli.os_os_system
GNU/Linux

```

**use by manual load**
```sh
$ require as demo github.com/shylinux/shell base/cli/os.sh
```

after load os.sh, you call all the function directly
```sh
$ ish_demo_os_system
GNU/Linux

$ ish_demo_os_kernel
Linux

```

## Create Plugins:
### add plugin
if the plugin named *demo*
add the code to the file $ISH_PATH/demo/demo.sh
```sh
ish set repos "github.com/xxx/xxx"
ish set owner "xxx@gmail.com"
ish set product "plugin demo"
ish set version "v0.0.1"

${ISH_CTX_SCRIPT}_info() { ish mod $0
    echo "repos: $(ish get repos)"
    echo "owner: $(ish get owner)"
    echo "product: $(ish get product)"
    echo "version: $(ish get version)"
}
${ISH_CTX_SCRIPT}_help() { ish mod $0
    echo "usage: ish mod/file.fun arg..."
}
${ISH_CTX_SCRIPT}_init() { ish mod $0
    pwd
}
```

### use plugin
use the new plugin
```sh
$ ish demo/demo_info
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
