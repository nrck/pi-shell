#!/bin/bash

# パッケージの更新
sudo apt-get update
sudo apt-get upgrade -y

# 必要なパッケージをインストール
sudo apt-get install -y --no-install-recommends \
    make \
    gcc \
    g++ \
    pcscd \
    pcsc-tools \
    dvb-tools \
    libccid \
    libdvbv5-dev \
    libpcsclite-dev \
    build-essential \
    automake \
    pkg-config \
    wget \
    git \
    vim \
    unzip \
    cmake \
    ffmpeg \
    raspberrypi-kernel \
    raspberrypi-kernel-headers

# 一旦再起動
sudo shutdown -r now
