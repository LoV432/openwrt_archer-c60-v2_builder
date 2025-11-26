FROM ubuntu:24.04

ARG version=24.10.4
ENV version=$version

ARG config_url=
ENV config_url=$config_url



RUN apt update

RUN apt -y install build-essential clang flex bison g++ gawk \
    gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
    python3-setuptools rsync swig unzip zlib1g-dev file wget

RUN useradd -ms /bin/bash openwrt

USER openwrt
WORKDIR /home/openwrt

RUN git clone https://git.openwrt.org/openwrt/openwrt.git \
    && cd openwrt \
    && git pull \
    && git checkout v${version} \
    && ./scripts/feeds update -a \
    && ./scripts/feeds install -a

WORKDIR /home/openwrt/openwrt

COPY .config .

USER root
RUN if [ -n "${config_url}" ]; then \
    wget -O .config ${config_url}; \
    else \
    echo "Using default config"; \
    fi
RUN chown openwrt:openwrt .config

USER openwrt

RUN make -j $(nproc) defconfig download clean world
