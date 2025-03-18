ARG BASEOS_DIGEST
FROM quay.io/centos/centos:stream9${BASEOS_DIGEST:-}

ENV container docker

RUN yum -y update \
    && yum -y install \
    epel-release \
    hostname \
    initscripts \
    iproute \
    openssl \
    python3.11 \
    sudo \
    which \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && yum clean all \
    # set python 3.11 as default
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

# selectively remove systemd targets -- See https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

STOPSIGNAL SIGRTMIN+3

VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]
