#!/bin/bash
tt=1
mgr_befor_init() {
         mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "
reset master;
flush logs;
SET SQL_LOG_BIN=0;
GRANT REPLICATION SLAVE ON *.* TO replicationuser@'%';
GRANT ALL ON *.* TO 'replicationuser'@'%' IDENTIFIED BY 'aabb234';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='replicationuser', MASTER_PASSWORD='aabb234'
                      FOR CHANNEL 'group_replication_recovery';

INSTALL PLUGIN group_replication SONAME 'group_replication.so';
SET GLOBAL group_replication_bootstrap_group=ON;
set global log_bin_trust_function_creators=TRUE;
set global group_replication_allow_local_disjoint_gtids_join=ON;
set global group_replication_ip_whitelist='127.0.0.1/24,GROUP_SEEDS1/32,GROUP_SEEDS2/32,GROUP_SEEDS3/32,DOCKERNET';
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
SELECT * FROM performance_schema.replication_group_members;
"
sleep 2 
exit 0 
}

remgr_befor_init() {

         mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "
#reset master;
#flush logs;
SET SQL_LOG_BIN=0;
GRANT REPLICATION SLAVE ON *.* TO replicationuser@'%';
GRANT ALL ON *.* TO 'replicationuser'@'%' IDENTIFIED BY 'aabb234';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='replicationuser', MASTER_PASSWORD='aabb234'
                      FOR CHANNEL 'group_replication_recovery';

SET GLOBAL group_replication_bootstrap_group=ON;
set global log_bin_trust_function_creators=TRUE;
set global group_replication_allow_local_disjoint_gtids_join=ON;
set global group_replication_ip_whitelist='127.0.0.1/24,GROUP_SEEDS1/32,GROUP_SEEDS2/32,GROUP_SEEDS3/32,DOCKERNET';
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
SELECT * FROM performance_schema.replication_group_members;
"
sleep 2 
exit 0 
}

mgr_after_init() {
     echo "wait mgr group"
     mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "
SELECT * FROM performance_schema.replication_group_members;
reset master;
flush logs;
SET SQL_LOG_BIN=0;
GRANT REPLICATION SLAVE ON *.* TO replicationuser@'%';
GRANT ALL ON *.* TO 'replicationuser'@'%' IDENTIFIED BY 'aabb234';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='replicationuser', MASTER_PASSWORD='aabb234'
                      FOR CHANNEL 'group_replication_recovery';
                  
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
set global log_bin_trust_function_creators=TRUE;
set global group_replication_allow_local_disjoint_gtids_join=ON;
set global group_replication_ip_whitelist='127.0.0.1/24,GROUP_SEEDS1/32,GROUP_SEEDS2/32,GROUP_SEEDS3/32,DOCKERNET';
START GROUP_REPLICATION;
SELECT * FROM performance_schema.replication_group_members;
"
sleep 2 
exit 0 
}

remgr_after_init() {
     echo "wait mgr group"
     mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "
SELECT * FROM performance_schema.replication_group_members;
#reset master;
#flush logs;
SET SQL_LOG_BIN=0;
GRANT REPLICATION SLAVE ON *.* TO replicationuser@'%';
GRANT ALL ON *.* TO 'replicationuser'@'%' IDENTIFIED BY 'aabb234';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='replicationuser', MASTER_PASSWORD='aabb234'
                      FOR CHANNEL 'group_replication_recovery';
set global log_bin_trust_function_creators=TRUE;
set global group_replication_allow_local_disjoint_gtids_join=ON;
set global group_replication_ip_whitelist='127.0.0.1/24,GROUP_SEEDS1/32,GROUP_SEEDS2/32,GROUP_SEEDS3/32,DOCKERNET';
START GROUP_REPLICATION;
SELECT * FROM performance_schema.replication_group_members;
"
sleep 2 
exit 0 
}

echo $tt
while [ $tt -le 4 ]
do
echo $tt
mysqladmin --defaults-extra-file=/healthcheck.cnf ping
 if [ $? -eq 0 ];then
   mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "CREATE USER replicationuser@'%' IDENTIFIED BY 'aabb234';" &
# break while
   tt=11
   mgroffline=$(mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "SELECT * FROM performance_schema.replication_group_members;" | grep group_replication_applier | grep OFFLINE | wc -l)
   mgronline=$(mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "SELECT * FROM performance_schema.replication_group_members;" | grep group_replication_applier | grep ONLINE | wc -l)
   mgrplugins=$(mysql -uroot -p$MYSQL_ROOT_PASSWORD -P${MYSQLPORT:-3306} -e "show plugins" | grep group_replication | grep ACTIVE | wc -l)
# Init mgr
   if [ $mgroffline -eq 0 ] && [ $mgronline -eq 0 ] &&  [ $MGR_FIRST == 'yes' ]; then     # 首先启动
     mgr_befor_init 

   elif [ $mgroffline -eq 0 ] && [ $mgronline -eq 0 ] && [ ! $MGR_FIRST == 'yes' ]; then   # 后启动
     mgr_after_init
   
   elif [ $mgroffline -eq 1 ] && [ $mgronline -eq 0 ] && [ $mgrplugins -eq 1 ] ; then # 重启后再次加入集群
     remgr_after_init 
   #elif [ $mgroffline -eq 1 ] && [ $mgronline -eq 0 ] && [ $MGR_FIRST == 'yes' ] ; then      # 全部节点宕机，集群消失，重新首先启动
     #remgr_befor_init
   #elif [ $mgroffline -eq 1 ] && [ $mgronline -eq 0 ] && [ ! $MGR_FIRST == 'yes' ] ; then      # 全部节点宕机，集群消失，重新后启动
     #remgr_after_init
   fi

 else
   sleep 0.05
   echo "Wait for initialization"
 fi
done
