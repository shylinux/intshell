

ish_ip_list() {
    ifconfig |grep -o "inet [0-9\.]\+" |grep -o "[0-9\.]\+" |grep -v 127
}

