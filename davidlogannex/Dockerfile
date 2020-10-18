from ruby:2.7

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y systemd initscripts locales locales-all wget apt-transport-https \
       build-essential pkg-config libmagickcore-6.q16-dev libssl-dev \
       git-annex \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
      /etc/systemd/system/*.wants/* \
      /lib/systemd/system/local-fs.target.wants/* \
      /lib/systemd/system/sockets.target.wants/*udev* \
      /lib/systemd/system/sockets.target.wants/*initctl* \
      /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
      /lib/systemd/system/systemd-update-utmp* \
    && echo installing ssh after systemd to have it actually start up \
    && apt-get install -y openssh-server openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /var/run/sshd \
    && adduser --uid 1000 --disabled-password david \
    && adduser --uid 1002 --disabled-password cheesy \
    && sed -ri "s/^#?UseDNS .*/UseDNS no/" /etc/ssh/sshd_config \
    && sed -e "/HostKey.*ssh_host_e.*_key/ s/^#*/#/" -ri /etc/ssh/sshd_config \
    && mkdir -p /etc/ssh/sshd_config.d

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["bash", "-e", "-c", "cp -av $SRV_DIR/secrets/ssh/* /etc/ssh/; echo -e \"Port $SSH_PORT\nSetEnv SRV_DIR=$SRV_DIR\" >> /etc/ssh/sshd_config; echo starting systemd; exec /lib/systemd/systemd"]
