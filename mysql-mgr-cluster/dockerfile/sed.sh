#!/bin/bash

GROUP_LOCAL=$(cat /etc/hostname)
# my.cnf
SEEDS1=`echo ${GROUP_SEEDS1} | awk -F ':' '{print $1}'` 
SEEDS2=`echo ${GROUP_SEEDS2} | awk -F ':' '{print $1}'`
SEEDS3=`echo ${GROUP_SEEDS3} | awk -F ':' '{print $1}'`
sed -i 's/SERVER_ID/'${SERVER_ID}'/g' /etc/my.cnf
if [[ $MGR_FIRST == "yes" ]]
then
  sed -i 's/GROUP_SEEDS1/'${GROUP_SEEDS3}'/g' /etc/my.cnf
  sed -i 's/GROUP_SEEDS2/'${GROUP_SEEDS2}'/g' /etc/my.cnf
  sed -i 's/GROUP_SEEDS3/'${GROUP_SEEDS1}'/g' /etc/my.cnf
else
  sed -i 's/GROUP_SEEDS1/'${GROUP_SEEDS1}'/g' /etc/my.cnf
  sed -i 's/GROUP_SEEDS2/'${GROUP_SEEDS2}'/g' /etc/my.cnf
  sed -i 's/GROUP_SEEDS3/'${GROUP_SEEDS3}'/g' /etc/my.cnf
fi
sed -i 's/MYSQLPORT/'${MYSQLPORT:-3306}'/g' /etc/my.cnf

sed -i 's/GROUP_LOCAL_IP_PORT/'${GROUP_LOCAL}:${GROUP_LOCAL_IP_PORT}'/g' /etc/my.cnf
# init mgr value
sed -i 's/GROUP_SEEDS1/'${SEEDS1}'/g' /mgrinit.sh 
sed -i 's/GROUP_SEEDS2/'${SEEDS2}'/g' /mgrinit.sh 
sed -i 's/GROUP_SEEDS3/'${SEEDS3}'/g' /mgrinit.sh 
sed -i 's#DOCKERNET#'${DOCKERNET}'#g' /mgrinit.sh 
