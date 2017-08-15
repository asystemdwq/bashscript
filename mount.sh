#!/bin/bash
# This script is written by Michael Wang from ResourcePro
# This script will used to check mount for JNBKSRV Linux backup job

#Define Variables
SSHFS="/usr/bin/sshfs"
email_addr="serversupportrequest@resourcepro.com.cn"
SERVERS=`ls /mnt |grep -Ev "(rsp-bugtracker2|sky|rsp-svn1|error.log|temprecord|mount.sh)"`
path="/mnt"
host_name='JN-LinuxBak'

#Check Error file, if not exist, creat it.

[ ! -e $path/error.log ] && touch $path/error.log || >$path/error.log

#Send Error Message
function send_error
{
    echo "$host_name bakcup library mount failed." |mail -s "Linux Backup Library Mount Failed" $email_addr -A $1
}

#Mount Servers root Directory
function mount_server ()
{
    for i in $SERVERS
    do
        $SSHFS $i:/ $path/$i 2>>$path/temprecord
    done
}

#Execute mount command
if [ -z $SERVERS ]
then
    echo "No directorys"
else
    mount_server
fi
/bin/egrep -v '(mountpoint is not empty|if you are sure this is safe)' $path/temprecord > $path/error.log
/bin/rm -rf $path/temprecord

#Send Alert Email
if [ -s $path/error.log ]
then
   send_error $path/error.log
fi
