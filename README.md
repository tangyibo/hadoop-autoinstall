# Hadoop-Install

基于ansible快速安装Hadoop相关组件

## 一、版本说明

### 1、基础软件

- 操作系统版本 CentOS 7.x

### 2、安装组件

安装组件及建议安装顺序如下：

- JDK 版本  Openjdk-1.8

- Hadoop 版本 3.2.1

- Hive 版本 3.1.2

- Zookeeper 版本 3.5.8

- Hbase 版本 1.4.13

- Spark 版本 2.4.7

## 二、安装准备

- (1) 部署机安装ansible：

使用yum安装ansible:

```
yum install -y epel-release
yum install -y ansible
```

- (2) 软件包下载：

执行如下命令联网下载软件包：

```
sh files/download_files.sh
```

- (3) 配置hosts.ini配置文件

安装文件格式配置主机IP及密码等，各个组件安装的节点等。

- (4) root免密及集群主机hosts配置

执行如下命令所有集群服务器/etc/hosts及root免密配置:

```
ansible-playbook -i hosts.ini prepare.yml
```

## 三、安装 Hadoop

### 1、参数配置

(1). 安装配置参数见vars/var_basic.yml中的内容：

(2). 采用ansible template动态生成配置文件, 如果你需要增加配置,可以直接更新vars/var_xxx.yml中相关properties数组。

---
**注意**
```
hdfs_site_properties:
  - {
      "name":"dfs.replication",
      "value":"{{ groups['workers']|length }}"  # this is  the group "workers" you define in hosts/host
  }
```

### 2、安装 Master

> 说明：这里 hadoop集群的master节点只能有一个

(1). 查看master.yml

```
- hosts: master
  remote_user: root
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_master.yml
  vars:
     add_user: true           # add user "hadoop"
     generate_key: true       # generate the ssh key
     open_firewall: true      # for CentOS 7.x is firewalld
     disable_firewall: false  # disable firewalld
     install_hadoop: true     # install hadoop,if you just want to update the configuration, set to false
     config_hadoop: true      # Update configuration
  roles:
    - user                    # add user and generate the ssh key
    - fetch_public_key        # get the key and put it in your localhost
    - authorized              # push the ssh key to the remote server
    - java                    # install jdk
    - hadoop                  # install hadoop
```

(2). 执行shell安装master节点

```
ansible-playbook -i hosts.ini master.yml
```

### 3、安装 Workers

(1). 查看 workers.yml

```
# Add Master Public Key   # get master ssh public key
- hosts: master
  remote_user: root
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_workers.yml
  roles:
    - fetch_public_key

- hosts: workers
  remote_user: root
  vars_files:
   - vars/user.yml
   - vars/var_basic.yml
   - vars/var_workers.yml
  vars:
    add_user: true
    generate_key: false # workers just use master ssh public key
    open_firewall: false
    disable_firewall: true  # disable firewall on workers
    install_hadoop: true
    config_hadoop: true
  roles:
    - user
    - authorized
    - java
    - hadoop
```

(2). 执行shell安装workers节点:

```
ansible-playbook -i hosts.ini workers.yml -e "master_ip=192.168.10.1 master_hostname=node1"
```

**说明**

> master_ip:  master节点的IP地址,示例为：192.168.10.1

> master_hostname: master节点的主机名(hostname)，示例为：node1

### 4、启动Hadoop集群

登录master节点，然后执行如下命令启动集群：

```
su - hadoop
hadoop namenode -format
sh start-all.sh
```

并分别检查下每个机器节点进程是否已经正常启动：
```
jps -l
```

启动完毕后，使用浏览器访问：

> Hadoop资源管理器管理界面：http://MASTER-IP:8088
>
> Hadoop的HDFS管理界面：http://MASTER-IP:9870
>

### 5、安装 hive

> 由于hive的元数据需要存储在关系数据库mysql或PostgreSQL中，故这里需要先安装MySQL数据库：

(1). 在任意一个节点上（通常在Master节点）上使用docker方式快速安装MySQL

```
sh sbin/docker_install.sh
rm -rf /var/lib/mysql/data/ && mkdir -p /var/lib/mysql/data/
docker pull mysql:5.7
docker run --name mysqldb  -p 3306:3306 -d \
    -e MYSQL_ROOT_PASSWORD=123456 \
    -e MYSQL_DATABASE=hive  \
    -e MYSQL_USER=hive_user \
    -e MYSQL_PASSWORD=nfsetso12fdds9s \
    -v /var/lib/mysql/data:/var/lib/mysql \
    mysql:5.7
```

(2). 查看 vars/var_hive.yml，并正确配置MySQL数据库的连接信息：

```
# database
db_type: "mysql"
hive_connection_driver_name: "com.mysql.jdbc.Driver"
hive_connection_host: "127.0.0.1"                # 这里填写MySQL的IP地址             
hive_connection_port: "3306"
hive_connection_dbname: "hive"
hive_connection_user_name: "hive_user"
hive_connection_password: "nfsetso12fdds9s"
hive_connection_url: "jdbc:mysql://{{ hive_connection_host }}:{{ hive_connection_port }}/{{hive_connection_dbname}}?useSSL=false"
```

(3). 执行shell安装hive：

```
ansible-playbook -i hosts.ini hive.yml
```

**说明**

> hive程序只会安装在hadoop的master节点上

(4). 配置hive的mysql驱动，并初始化hive元数据库

登录master节点后：
```
su - hadoop

cd apache-hive-3.1.2-bin/lib

# 这里解决jar包冲突问题，参考：https://blog.csdn.net/xiaozhu123412/article/details/106367859/
rm -f guava-19.0.jar
cp ~/hadoop-3.2.1/share/hadoop/common/lib/guava-27.0-jre.jar .

wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar

schematool -initSchema -dbType mysql
```

(5). hive测试

```
hive -e " show databases"
```

### 6、安装Zookeeper

(1). 查看 vars/var_zk.yml的参数配置

(2). 执行shell命令安装hbase:

```
ansible-playbook -i hosts.ini  zookeeper.yml
```

### 7、安装Hbase

> 由于hbase依赖zookeeper，所以事先应先安装zookeeper

(1). 查看 vars/var_hbase.yml的参数配置;

(2). 检查hosts.ini中zookeeper节点的配置；

(3). 执行shell命令安装hbase:

```
ansible-playbook -i hosts.ini  hbase.yml
```

**说明**
> 1. hosts.ini中配置必须在master节点上安装hbase

(4). 执行shell启动hbase

登录master节点,执行如下命令启动hbase:

```
su - hadoop
sh start-hbase.sh
```

(5). hbase测试

```
su - hadoop
hbase shell
hbase(main):001:0> create 'emp','id','name'
```

(6). 浏览器访问WEB

用浏览器访问地址： http://MASTER-IP:60010/

### 5、安装spark

(1). 下载scala和spark到本机 {{ download_path }}

(2). 查看vars/var_spark.yml

(3). 增加spark 到 hosts.ini

```
[spark]
node1
node2
node3
node4
```

(4). 查看spark.yml

(5). 执行shell安装

```
ansible-playbook -i hosts.ini  spark.yml -e "master_hostname=node1"
```
**说明**

> master_hostname: spark.master节点的主机名(hostname)，示例为：node1

## 四、声明

本项目参考：https://gitee.com/pippozq/hadoop-ansible

在该项目实践的基础上，进行了改进，并完善了一些文档内容。

