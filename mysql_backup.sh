#!/bin/bash

# How to use
# my_script_name bd_user db_pass project_name(should be same name on database and project_directory)
# by Alfredo Ribeiro: alfredo@aatecnologia.com.br
# Create the daily backup, delete old backups, and each month, make a copy last backup on a separated directory

mysql_user=$1
mysql_pass=$2
project_name=$3

suffix=$(date +%Y%m%d)
last_day_on_month=$(cal `date '+%m'` `date '+%Y'` | grep . | fmt -1 | tail -1)
today=$(date +%d)
month_bkp=$(date +%Y-%B)
host=127.0.0.1
daily_bkp_dir='/home/user/bkps/daily'
monthly_bkp_dir='/home/user/bkps/monthly'

if [ ! -d /tmp/mysql ]; then
  mkdir /tmp/mysql
fi

if [ ! -d $daily_bkp_dir ]; then
  mkdir -p $daily_bkp_dir
fi

if [ ! -d $monthly_bkp_dir ]; then
  mkdir -p $monthly_bkp_dir
fi

# daily backup
mysqldump --opt -u$mysql_user -p$mysql_pass -h $host  $project_name > /tmp/mysql/$project_name.$suffix.sql
tar -cvzf /tmp/mysql/$project_name-db-$suffix.tar.gz $daily_bkp_dir/

# copy last backup of each month to a separated place
if [ $today -eq $last_day_on_month ]; then
  mv /tmp/$project_name-db-$suffix.tar.gz $monthly_bkp_dir/$project_name-db-$month_bkp.tar.gz
fi

rm -rf /tmp/mysql

#remove daily backups with more than 10 days
find $daily_bkp_dir -ctime +10 -exec rm -rf {} \;
