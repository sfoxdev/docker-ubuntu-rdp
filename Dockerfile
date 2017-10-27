FROM ubuntu:16.04
MAINTAINER SFoxDev <admin@sfoxdev.com>

ENV PASSWORD="" \
		DEBIAN_FRONTEND="noninteractive" \
		TERM="xterm" \
    LC_ALL="C.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

ADD https://dl.google.com/linux/linux_signing_key.pub /tmp/

RUN sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list ; \
    apt-key add /tmp/linux_signing_key.pub ; \
    echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list ; \
    echo 'deb http://dl.google.com/linux/chrome-remote-desktop/deb/ stable main' >> /etc/apt/sources.list ; \
    apt-get -y update ; \
    apt-get -yy upgrade

ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
    libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
    bison libxml2-dev dpkg-dev libcap-dev"

RUN apt-get -yy install \
    sudo apt-utils software-properties-common vim wget ca-certificates \
    xfce4 xfce4-terminal xfce4-screenshooter xfce4-taskmanager \
    xfce4-clipman-plugin xfce4-cpugraph-plugin xfce4-netload-plugin \
    xfce4-xkb-plugin xauth supervisor uuid-runtime pulseaudio locales \
    pepperflashplugin-nonfree openssh-server \
    google-chrome-stable x11vnc mc \
    $BUILD_DEPS ; \
    cd /tmp ; \
    apt-get source pulseaudio ; \
    apt-get build-dep -yy pulseaudio ; \
    cd /tmp/pulseaudio-8.0 ; \
    dpkg-buildpackage -rfakeroot -uc -b ; \
    cd /tmp ; \
    git clone --branch v0.9.4 --recursive https://github.com/neutrinolabs/xrdp.git ; \
    cd /tmp/xrdp ; \
    ./bootstrap ; ./configure ; make ; make install ; \
    cd /tmp/xrdp/sesman/chansrv/pulse ; \
    sed -i "s/\/tmp\/pulseaudio\-10\.0/\/tmp\/pulseaudio\-8\.0/g" Makefile ; \
    make ; \
    cp *.so /usr/lib/pulse-8.0/modules/ ; \
    cd /tmp ; \
    git clone --branch v0.2.4 --recursive https://github.com/neutrinolabs/xorgxrdp.git ; \
    apt-get -yy install xserver-xorg-dev ; \
    cd /tmp/xorgxrdp ; \
    ./bootstrap ; ./configure ; make ; make install ; \
    cd / ; \
    apt-get -yy remove xscreensaver $BULD_DEPS ; \
    apt-get -yy autoremove ; \
    apt-get -yy clean ; \
    rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/*

ADD data/ /

RUN mkdir /var/run/dbus ; \
    cp /etc/X11/xrdp/xorg.conf /etc/X11 ; \
#sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config ; \
    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini ; \
    locale-gen en_US.UTF-8 ; \
    echo "xfce4-session" > /etc/skel/.Xclients ; \
    cp -r /etc/ssh /ssh_orig ; \
    rm -rf /etc/ssh/* ; \
    rm -rf /etc/xrdp/rsakeys.ini /etc/xrdp/*.pem ; \

    addgroup chrome ; \
    useradd -m -s /bin/bash -g chrome chrome ; \
    echo "chrome:chrome" | /usr/sbin/chpasswd ; \
    echo "chrome    ALL=(ALL) ALL" >> /etc/sudoers

#VOLUME ["/etc/ssh","/home"]

EXPOSE 3389 22 9001

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

CMD ["supervisord"]
