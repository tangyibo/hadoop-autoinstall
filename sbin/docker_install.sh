#!/bin/bash

set -e

# 安装yum源
yum -y install yum-utils
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装最新的docker软件包
yum -y install docker-ce

# 配置docker仓库源地址
mkdir -p /etc/docker/
cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors":[
        "https://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com"
    ],
    "insecure-registries": ["127.0.0.1/8"],
    "max-concurrent-downloads":10,
    "log-driver":"json-file",
    "log-level":"warn",
    "log-opts":{
        "max-size":"10m",
        "max-file":"3"
    },
    "data-root":"/var/lib/docker"
}
EOF

# 启动并查看docker服务
systemctl start docker.service
systemctl enable docker.service
systemctl status docker.service

