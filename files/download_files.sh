#!/bin/bash
############################################
# Function :  hadoop/hive/hbase等软件安装包下载脚本
# Author : tang
# Date : 2020-10-21
#
# Usage: sh download_files.sh
#
############################################
set -e

SCRIPT_PATH=$(cd `dirname $0`; pwd)

cd $SCRIPT_PATH/

# 下载hadoop软件包
if [ ! -f "$SCRIPT_PATH/hadoop-3.2.1.tar.gz" ]; then
    wget https://mirror.bit.edu.cn/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
fi

# 下载hive软件包
if [ ! -f "$SCRIPT_PATH/apache-hive-3.1.2-bin.tar.gz" ]; then
    wget https://mirror.bit.edu.cn/apache/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz
fi

# 下载Zookeeper
if [ ! -f "$SCRIPT_PATH/apache-zookeeper-3.5.8-bin.tar.gz" ]; then
    wget https://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.5.8/apache-zookeeper-3.5.8-bin.tar.gz
fi

# 下载hbase软件包
if [ ! -f "$SCRIPT_PATH/hbase-1.4.13-bin.tar.gz" ]; then
    wget https://mirror.bit.edu.cn/apache/hbase/1.4.13/hbase-1.4.13-bin.tar.gz
fi

# 下载scaka软件包
if [ ! -f "$SCRIPT_PATH/scala-2.12.12.tgz" ]; then
    wget https://downloads.lightbend.com/scala/2.12.12/scala-2.12.12.tgz
fi

# 下载spark软件包
if [ ! -f "$SCRIPT_PATH/spark-2.4.7-bin-hadoop2.7.tgz" ]; then
    wget https://mirror.bit.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
fi


ls -l $SCRIPT_PATH
