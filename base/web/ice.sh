#!/bin/sh

ish_ctx_dev_ice_pwd() {
    [ -f bin/ice.sh ] || curl -so bin/ice.sh --create-dirs $ctx_dev/publish/ice.sh
    chmod u+x bin/ice.sh && bin/ice.sh
}
