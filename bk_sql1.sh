#!/bin/bash

#this:s script is written by Chandler Wang from ReSource Pro

# This script will be used to backup Linux folders and databases
#
#Define variables
p_path=` dirname $0`
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"
bk_dir="/var/lib/mysql/backup"
db_user='root'
db_password='db3p%H$ee%'
db_ip='localhost'
email_addr='itsupport@resourcepro.com.cn'
h_name='RSP-MYSQL1'
#Get a list of all databases and backup everyone EXCEPT information_schema
s_db=`$MYSQL --user=$db_user --password=$db_password -e "SHOW DATABASES;" | tr -d "| " | grep -Ev "(Database|information_schema|xwiki_new|performance_schema|ITMetricsWarehouse|otrs)"`
#s_db='xwiki'


#Check error files. If not exists, create a new one
[ ! -e $p_path/mysqldump.err ] && touch $p_path/mysqldump.err || >$p_path/mysqldump.err
#Check database folder
if [ ! -d $bk_dir/db/ ]
then
     mkdir -p $bk_dir/db/
fi

#Send OK messages
function send_ok
{
    echo "$h_name Database Backup Alert: Job Success!"|mutt -s "$h_name Database Backup successfully" $email_addr
}

#Send Error messages
function send_error
{
    echo "$h_name Database error occurs, please check attachments"|mutt -s "$h_name Database Backup Failed" $email_addr -a $1
}

#Backup database
function bksql ()
{
    for i in $s_db
    do
         $MYSQLDUMP --lockl-tables=false -R -E -u $db_user -p${db_password} -h $db_ip --max_allowed_packet=1024M --databases $i > $bk_dir/db/$i.sql 2>>$p_path/mysqldump.err
	echo $i - 'date +"%m-%d-%Y"' >> $p_path/backdate
    done
}

#Execute backup script
if [ -z "$s_db " ]
then
     echo "No Source Database"
else
     bksql
fi
#Sending alert email
if [ ! -s $p_path/mysqldump.err ]
then
        send_ok
else
        [ ! -s $p_path/mysqldump.err ] && echo "No Error" || send_error $p_path/mysqldump.err
fi

