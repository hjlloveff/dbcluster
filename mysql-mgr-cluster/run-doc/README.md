# mysql mgr cluster 

-------------------

[TOC]

##说明
### 集群类型

> mgr  多主，目前适配的是三主

### 参考手册
> https://dev.mysql.com/doc/refman/5.7/en/preface.html

### 限制要求
> 
1.  每台机器需要映射为3306端口，此端口在恢复时需要使用，非docker环境无此要求
2.  因为docker特殊环境，使用各自host文件解析主机名，实现本机解析容器ip，其他主机解析物理ip
3.  只支持三主，其他数量主机未做适配
4.  未做三台同时宕机的自动回复，需要手动参与
### 灾难恢复
> 重启即可

### 退出重新加入集群
> 如果重启后加入集群失败
> 参考容器中  /mgpinit.sh  的  remgr_after_init  方法

### 集群状态检查
``` python
SELECT  *  FROM  performance_schema.replication_group_members;
#  检查集群现在的状态

select  *  from  performance_schema.replication_group_member_stats;
#  与认证过程相关的信息。信息在作为复制组成员的所有服务器实例之间共享，因此可以从任何成员查询有关所有组成员的信息。

select  *  from  performance_schema.replication_connection_status;
#  连接到组时，此表中的某些字段显示有关组复制的信息。例如，已从组接收并在应用程序队列（中继日志）中排队的事务。

select  *  from  performance_schema.replication_applier_status;
#  常规replication_applier_status表来观察与Group  Replication相关的通道和线程的状态。如果有许多不同的工作线程应用事务，那么工作表也可用于监视每个工作线程正在做什么。
```

## 示例
> docker-compose 文件请参见其他三个docker-compose文件，都可以在公司以上机器直接运行
### 环境说明
> 容器名称：宿主机IP
                mysql3306:172.16.101.143  mysql3307:172.16.101.100  mysql3308:172.16.101.50

#### mysql3306在172.16.101.143中启动
``` python 
sudo  rm  -rf  /home/deployer/dcmysql/33061  ;  docker  rm  -f  mysql3306
docker  run  -d  -p  3306:3306  -p  33060:33060  --hostname  mysql3306  --name  mysql3306  --privileged=true    -v  /home/deployer/dcmysql/33061:/var/lib/mysql:rw  --add-host  mysql3306:172.16.101.143  --add-host  mysql3307:172.16.101.100  --add-host  mysql3308:172.16.101.50  --env  GROUP_SEEDS1=172.16.101.143:33060  --env  GROUP_SEEDS2=172.16.101.100:33070  --env  GROUP_SEEDS3=172.16.101.50:33080  --env  DOCKERNET=172.17.0.0/16,172.16.101.0/24  --env  MGR_FIRST=yes  --env  SERVER_ID=1  --env  GROUP_LOCAL_IP_PORT=33060    --env  MYSQL_RANDOM_ROOT_PASSWORD=  --env  MYSQL_ROOT_PASSWORD='aabb123'  --env  MYSQL_LOG_CONSOLE=true  --env  MYSQL_ALLOW_EMPTY_PASSWORD=    --env  MYSQL_ONETIME_PASSWORD=    --env  MYSQL_ROOT_HOST=%  docker-reg.emotibot.com.cn:55688/mgpmysql:5.7.22
```
#### mysql3307在172.16.101.100中启动
``` python
sudo  rm  -rf  /home/deployer/dcmysql/33071  ;    docker  rm  -f  mysql3307
docker  run  -d  -p  3306:3306  -p  33070:33070  --hostname  mysql3307  --name  mysql3307  --privileged=true  -v  /home/deployer/dcmysql/33071:/var/lib/mysql:rw    --add-host  mysql3306:172.16.101.143  --add-host  mysql3307:172.16.101.100  --add-host  mysql3308:172.16.101.50  --env  GROUP_SEEDS1=172.16.101.143:33060  --env  GROUP_SEEDS2=172.16.101.100:33070  --env  GROUP_SEEDS3=172.16.101.50:33080  --env  DOCKERNET=172.17.0.0/16,172.16.101.0/24  --env  MGR_FIRST=no  --env  SERVER_ID=2    --env  GROUP_LOCAL_IP_PORT=33070  --env  MYSQL_RANDOM_ROOT_PASSWORD=    --env  MYSQL_ROOT_PASSWORD='aabb123'  --env  MYSQL_LOG_CONSOLE=true  --env  MYSQL_ALLOW_EMPTY_PASSWORD=    --env  MYSQL_ONETIME_PASSWORD=    --env  MYSQL_ROOT_HOST=%  docker-reg.emotibot.com.cn:55688/mgpmysql:5.7.22
```
#### mysql3308在172.16.101.50中启动
```python
sudo  rm  -rf  /home/deployer/dcmysql/33081  ;    docker  rm  -f  mysql3308
docker  run  -d  -p  3306:3306  -p  33080:33080  --hostname  mysql3308  --name  mysql3308  --privileged=true    -v  /home/deployer/dcmysql/33081:/var/lib/mysql:rw  --add-host  mysql3306:172.16.101.143  --add-host  mysql3307:172.16.101.100  --add-host  mysql3308:172.16.101.50  --env  GROUP_SEEDS1=172.16.101.143:33060  --env  GROUP_SEEDS2=172.16.101.100:33070  --env  GROUP_SEEDS3=172.16.101.50:33080  --env  DOCKERNET=172.17.0.0/16,172.16.101.0/24  --env  MGR_FIRST=no  --env  SERVER_ID=3  --env  GROUP_LOCAL_IP_PORT=33080  --env  MYSQL_RANDOM_ROOT_PASSWORD=    --env  MYSQL_ROOT_PASSWORD='aabb123'  --env  MYSQL_LOG_CONSOLE=true  --env  MYSQL_ALLOW_EMPTY_PASSWORD=    --env  MYSQL_ONETIME_PASSWORD=    --env  MYSQL_ROOT_HOST=%  docker-reg.emotibot.com.cn:55688/mgpmysql:5.7.22
```


