
ish_miss_local() {
    docker exec -it ${PWD##*/} sh
}
ish_miss_centos() {
    docker run $(ish_miss_docker_args) -it centos sh
}
ish_miss_alpine() {
    docker run $(ish_miss_docker_args) -it alpine sh
}
ish_miss_docker() {
    docker run $(ish_miss_docker_args) -it shylinux/contexts "$@"
}
ish_miss_docker_args() {
    echo "--mount type=bind,source=${PWD},target=/root -w /root -e ctx_dev=$ctx_dev -e ctx_user=$USER"
}
ish_miss_docker_image() {
    local name=contexts && [ "$1" != "" ] && name=$1

    rm -rf usr/docker/meta
    mkdir -p usr/docker/meta/volcanos && cp -r usr/volcanos/* usr/docker/meta/volcanos/
    mkdir -p usr/docker/meta/learning && cp -r usr/learning/* usr/docker/meta/learning/
    mkdir -p usr/docker/meta/icebergs && cp -r usr/icebergs/* usr/docker/meta/icebergs/
    mkdir -p usr/docker/meta/linux-story && cp -r usr/linux-story/* usr/docker/meta/linux-story/
    cp -r usr/demo usr/docker/meta

    local target=/usr/local/bin
    ish_miss_create_file usr/docker/$name <<END
# FROM busybox

FROM alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN mkdir /root/src /root/etc /root/bin /root/var /root/usr
ADD $ctx_dev/publish/ice.sh /usr/local/bin/ice.sh
ADD $ctx_dev/publish/ice.linux.amd64 /usr/local/bin/ice.bin
ADD $ctx_dev/publish/init.shy /root/etc/init.shy
ADD $ctx_dev/publish/main.svg /root/src/main.svg
ADD $ctx_dev/publish/main.shy /root/src/main.shy
RUN chmod u+x /usr/local/bin/*

RUN mkdir -p /root/usr/publish
ADD $ctx_dev/publish/order.js /root/usr/publish/order.js

RUN mkdir -p /root/usr/volcanos
COPY meta/volcanos /root/usr/volcanos
COPY meta/learning /root/usr/learning
COPY meta/icebergs /root/usr/icebergs
COPY meta/linux-story /root/usr/linux-story
COPY meta/demo /root/usr/demo

ENV ctx_dev $ctx_dev
ENV ctx_user root
WORKDIR /root
EXPOSE 9020
CMD /usr/local/bin/ice.sh start serve dev
END

    docker build usr/docker/ -f usr/docker/$name -t $name
}

