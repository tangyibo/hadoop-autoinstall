# Hadoop-Auto-Installer

## 一、安装说明

基于ansible的快速安装Hadoop相关生态组件工具。

### 1、操作系统

- 操作系统版本 CentOS 7.x

### 2、安装组件

安装组件如下：

- JDK 版本  Openjdk-1.8

- Hadoop 版本 3.1.3

- Hive 版本 3.1.2

- Zookeeper 版本 3.5.9

- Hbase 版本 2.2.2

- Spark 版本 2.4.5

## 二、安装准备

选择要安装的主机节点中的一个作为部署机，然后安装如下步骤操作：

- 1、部署机安装ansible：

使用yum安装ansible:

```
# yum install -y epel-release
# yum install -y ansible
```

- 2、软件包下载：

将本项目克隆到master节点上，安装如下命令下载项目：

```
# git clone https://github.com/tangyibo/hadoop-autoinstall.git
# cd hadoop-autoinstall/
```

执行如下命令联网下载软件包:

```
# sh files/download_files.sh
```

或者到百度云盘下载：

> 百度云盘下载地址：
> 链接：https://pan.baidu.com/s/132YKx_WqsYSzVM_LU4-9Vg 
> 提取码：vvvs 
> 请将百度云盘中下载的文件放到files目录下

- 3、配置hosts.ini配置文件

安装文件格式配置主机IP及密码等，各个组件安装的节点等。

- 4、root免密及集群主机hosts配置

执行如下命令配置所有集群服务器/etc/hosts及root免密配置等基础配置:

```
# ansible-playbook -i hosts.ini prepare.yml
```

## 三、安装 Hadoop

### 1、参数配置

(1). 安装配置参数见vars/var_basic.yml中的内容：

(2). 采用ansible的template动态生成配置文件, 如果需要增加或调整配置,可更新vars/var_xxx.yml中相关properties数组:

**注意**
```
hdfs_site_properties:
  - {
      "name":"dfs.replication",
      "value":"{{ groups['workers']|length }}"  # 副本数
  }
```

### 2、安装 Hadoop(HDFS+YARN)

> 安装hadoop集群的master节点，即HDFS的NameServer、SecondaryNameNode、ResourceManager所在节点，如果想要调整可直接修改vars/var_basic.yml里的配置：

```
# ansible-playbook -i hosts.ini hadoop.yml -e "master_hostname=node1"
```

**说明**

> master_hostname: master节点的主机名(hostname)，示例为：node1

### 4、启动Hadoop集群

登录master节点（这里为node1），然后执行如下命令启动集群：

```
# su - hadoop
$ hadoop namenode -format
$ start-all.sh
```

**说明：**不能使用sh start-all.sh启动，原因见：https://blog.csdn.net/JHC_binge/article/details/83547504

并执行如下命令检查所有节点是否已经正常启动：
```
# ansible -i hosts.ini nodes -m shell -a "jps -l"
```

启动完毕后，使用浏览器访问：

> Hadoop的HDFS管理界面：http://MASTER-IP:9870
>
> Hadoop的YARN管理界面：http://MASTER-IP:8088

## 四、安装 hive

> 由于hive的元数据需要存储在关系数据库mysql或PostgreSQL中，这里选择安装MySQL数据库：

(1). 在任意一个节点上（通常在Master节点）上使用docker方式快速安装MySQL

```
# sh sbin/docker_install.sh
# rm -rf /var/lib/mysql/data/ && mkdir -p /var/lib/mysql/data/
# docker pull mysql:5.7
# docker run --name mysqldb  -p 3306:3306 -d \
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
# ansible-playbook -i hosts.ini hive.yml
```

**说明**

> hive程序只会安装在hadoop的master节点上

(4). 配置hive的mysql驱动，并初始化hive元数据库

登录master节点后：
```
# yum install -y wget
# su - hadoop

# 这里解决jar包冲突问题，参考：https://blog.csdn.net/xiaozhu123412/article/details/106367859/
$ rm -f $HIVE_HOME/lib/guava-19.0.jar
$ cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

# 下载mysql的jdbc驱动包，如果未安装wget命令，请先执行：yum install -y wget
$ wget -P $HIVE_HOME/lib/  https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar

# 初始化mysql元数据库
$ schematool -initSchema -dbType mysql
```

(5). hive测试

```
$ hive -e " show databases"
```

(6). 开启hiveserve2进行jdbc连接

```
[root@node1 ~]# su - hadoop
[hadoop@node1 ~]$ hiveserver2 >> ~/hiveserver2.log &
[hadoop@node1 ~]$ beeline
beeline> ! connect jdbc:hive2://127.0.0.1:10000
Connecting to jdbc:hive2://127.0.0.1:10000
Enter username for jdbc:hive2://127.0.0.1:10000: hadoop
Enter password for jdbc:hive2://127.0.0.1:10000: ******
Connected to: Apache Hive (version 3.1.2)
Driver: Hive JDBC (version 3.1.2)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://127.0.0.1:10000> show databases;
+----------------+
| database_name  |
+----------------+
| default        |
+----------------+
1 row selected (0.583 seconds)
0: jdbc:hive2://127.0.0.1:10000>
```

打开浏览器访问如下地址查看hiveserve2的监控界面：

http://MASTER-IP:10002/

关于配置jdbc连接认证可参考文章： https://blog.csdn.net/lr131425/article/details/72628001

## 五、安装Zookeeper

(1). 查看 vars/var_zk.yml的参数配置

(2). 执行shell命令安装zookeeper:

```
# ansible-playbook -i hosts.ini  zookeeper.yml
```
(3) 使用客户端连接验证:

```
# su - hadoop
$ zkCli.sh -server 127.0.0.1:12181
Connecting to 127.0.0.1:12181
Welcome to ZooKeeper!
JLine support is enabled
[zk: 127.0.0.1:12181(CONNECTING) 0] 
```

## 六、安装Hbase

> 由于hbase依赖zookeeper，所以事先应先安装zookeeper

(1). 查看 vars/var_hbase.yml的参数配置;

(2). 检查hosts.ini中zookeeper节点的配置；

(3). 执行shell命令安装hbase:

```
# ansible-playbook -i hosts.ini  hbase.yml
```

**说明**
> hosts.ini中配置必须在master节点上安装hbase

(4). 执行shell启动hbase

登录master节点,执行如下命令启动hbase:

```
# su - hadoop
$ start-hbase.sh
```

(5). hbase测试

```
# su - hadoop
$ hbase shell
hbase(main):001:0> status
hbase(main):001:0> create 'emp','id','name'
```

(6). 浏览器访问WEB管理页

用浏览器访问地址： http://MASTER-IP:60010/

## 七、安装spark

(1). 查看vars/var_spark.yml

(2). 增加spark 到 hosts.ini

(3). 查看spark.yml

(4). 执行shell安装

```
# ansible-playbook -i hosts.ini  spark.yml -e "master_hostname=node1"
```
**说明**

> master_hostname: spark.master节点的主机名(hostname)，示例为：node1

(5) 启动与验证安装

```
# su - hadoop
$ cd /usr/local/spark-2.4.5-bin-without-hadoop/
$ ./start-all.sh
$ run-example SparkPi
```
**说明**: 由于hadoop的start-all.sh与spark的start-all.sh重名了，故没有将spark目录下的sbin目录加入到环境变量PATH里。

打开浏览器访问如下地址查看spark的监控界面：

http://MASTER-IP:18080/

