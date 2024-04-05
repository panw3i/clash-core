#!/bin/bash

# 更新系统包列表
echo "更新系统包列表..."
sudo apt-get update

# 检查Node.js是否安装
if ! command -v node > /dev/null 2>&1; then
    echo "Node.js未安装，正在安装..."
    # 使用NodeSource Node.js 16.x版本，你也可以选择其他版本
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js已安装"
fi

# 检查npm是否安装
if ! command -v npm > /dev/null 2>&1; then
    echo "npm未安装，正在安装..."
    sudo apt-get install -y npm
else
    echo "npm已安装"
fi

# 全局安装PM2
echo "正在全局安装PM2..."
sudo npm install pm2@latest -g

# 设置PM2开机自启
echo "设置PM2开机自启..."
pm2_startup=$(pm2 startup systemd | grep 'sudo' | sed -n -e 's/^.*\(sudo .*\)$/\1/p')
eval $pm2_startup

# 下载并安装Clash
echo "下载并安装Clash..."
clash_dir="$HOME/clash"
mkdir -p $clash_dir
wget https://github.com/Kuingsmile/clash-core/releases/download/1.18/clash-linux-amd64-v1.18.0.gz -O $clash_dir/clash-linux-amd64-v1.18.0.gz
gunzip -f $clash_dir/clash-linux-amd64-v1.18.0.gz

# 赋予Clash执行权限
chmod +x $clash_dir/clash-linux-amd64-v1.18.0

echo "安装完成。"

# 保存PM2进程列表
echo "保存PM2进程列表..."
pm2 save



#启动

pm2 start ./clash-linux-amd64-v1.18.0 --name="clash-service" -- -f glados.yaml
