#!/bin/bash

# Node.js v18のインストール
NODE_MAJOR=18
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update
sudo apt-get install nodejs -y

# PM2のインストール
sudo npm install pm2 --location=global
sudo pm2 startup

# Mirakurunのインストール
sudo npm install mirakurun@3.8.1 --location=global --production
sudo mirakurun init

# v3.8.1を経由しないと3.9.xに上げられない
sudo npm install mirakurun --location=global --production
sudo mirakurun restart

# Node.jsのバージョン確認
echo -n "*** Node.js Version: "
node -v

# npmのバージョン確認
echo -n "*** npm Version: "
npm -v

# PM2のバージョン確認
echo "*** pm2 Version: "
pm2 -v

# Mirakurunのバージョン確認
echo "*** Mirakurun Version: "
sudo mirakurun version
