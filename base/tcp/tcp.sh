#!/bin/sh

ish_ctx_tcp_ip() {
    ifconfig |grep -o "inet [0-9\.]\+" |grep -o "[0-9\.]\+" |grep -v 127
}

