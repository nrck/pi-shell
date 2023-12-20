#!/bin/bash

# ホームディレクトリに移動
cd ~

# Gitからファームウェアツールをクローン
git clone https://github.com/nns779/px4_drv.git
cd px4_drv/fwtool

# ファームウェアツールのビルド
make

# PX-W3U4ドライバのダウンロード
wget http://plex-net.co.jp/download/pxw3u4v1.4.zip -O pxw3u4v1.4.zip
if [ $? -ne 0 ]; then
    echo "Error: pxw3u4v1.4.zip download"
    exit 1
fi

# PX-W3U4ドライバの解凍
unzip -oj pxw3u4v1.4.zip pxw3u4v1/x64/PXW3U4.sys

# ファームウェアの作成
./fwtool PXW3U4.sys it930x-firmware_pxw3u4.bin

# ファームウェアの配置
sudo mkdir -p /lib/firmware
sudo mv it930x-firmware_pxw3u4.bin /lib/firmware/it930x-firmware.bin

# クリーン
rm ./pxw3u4v1.4.zip
rm ./PXW3U4.sys

# DKMSを使用してドライバのインストール
cd ../
sudo cp -a ./ /usr/src/px4_drv-0.2.1
sudo dkms add px4_drv/0.2.1
sudo dkms install px4_drv/0.2.1
if [ $? -ne 0 ]; then
  echo "Error: px4_drv install"
  exit 1
fi

# カーネルモジュールのロードの確認
sudo modprobe px4_drv
lsmod | grep -e ^px4_drv
if [ $? -ne 0 ]; then
  echo "Error: modprobe px4_drv"
  exit 1
fi

# 環境設定
cat /boot/cmdline.txt | grep coherent_pool=4M
if [ "$?" -ne "0" ]; then
  echo -n `cat /boot/cmdline.txt` coherent_pool=4M > ./cmdline.txt
  sudo cp ./cmdline.txt /boot/cmdline.txt
  rm ./cmdline.txt
fi

cat /etc/modules | grep px4_drv
if [ "$?" -ne "0" ]; then
  cat /etc/modules > ./modules
  echo px4_drv >> ./modules
  sudo cp ./modules /etc/modules
  rm ./modules
fi

echo "Setup Finished."
