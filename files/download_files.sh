#!/bin/bash
######################################################################
# Function :  hadoop/hive/zookeeper/hbase/spark等软件安装包下载脚本
# Author : tang
# Date : 2020-10-21
#
# Usage: sh download_files.sh
#
######################################################################
set -e

SCRIPT_PATH=$(cd `dirname $0`; pwd)
MIRROR_SITE="https://mirrors.huaweicloud.com"
cd $SCRIPT_PATH/

yum install -y wget

# 下载hadoop软件包
if [ ! -f "$SCRIPT_PATH/hadoop-3.1.3.tar.gz" ]; then
    wget $MIRROR_SITE/apache/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz &
fi

# 下载hive软件包
if [ ! -f "$SCRIPT_PATH/apache-hive-3.1.2-bin.tar.gz" ]; then
    wget $MIRROR_SITE/apache/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz &
fi

# 下载Zookeeper
if [ ! -f "$SCRIPT_PATH/apache-zookeeper-3.5.9-bin.tar.gz" ]; then
    wget $MIRROR_SITE/apache/zookeeper/zookeeper-3.5.9/apache-zookeeper-3.5.9-bin.tar.gz &
fi

# 下载hbase软件包
if [ ! -f "$SCRIPT_PATH/hbase-2.2.2-bin.tar.gz" ]; then
    wget $MIRROR_SITE/apache/hbase/2.2.2/hbase-2.2.2-bin.tar.gz &
fi

# 下载scaka软件包
if [ ! -f "$SCRIPT_PATH/scala-2.12.14.tgz" ]; then
    wget https://downloads.lightbend.com/scala/2.12.14/scala-2.12.14.tgz &
fi

# 下载spark软件包
if [ ! -f "$SCRIPT_PATH/spark-2.4.5-bin-without-hadoop.tgz" ]; then
    wget $MIRROR_SITE/apache/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz &
fi

wait

ls -l $SCRIPT_PATH
