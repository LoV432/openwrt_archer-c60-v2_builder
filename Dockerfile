FROM ubuntu


RUN apt update

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

RUN apt -y install build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev \
libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
python3-distutils python3-setuptools python3-dev rsync subversion \
swig time xsltproc zlib1g-dev

RUN useradd -ms /bin/bash openwrt

USER openwrt
WORKDIR /home/openwrt

RUN git clone https://git.openwrt.org/openwrt/openwrt.git \
    && cd openwrt \
    && git pull \
    && git checkout v21.02.1 \
    && ./scripts/feeds update -a \
    && ./scripts/feeds install -a

COPY .config openwrt/

USER root

RUN cd openwrt && chown openwrt:openwrt .config

USER openwrt

RUN cd openwrt \
    && make -j $(nproc) defconfig download clean world
