#!/bin/bash
echo "Welcome to Michael Wang's script!"
echo -n "Enter the date you want to print:"
read d
cat /home/mwang/Documents/New_Hire.csv | while read line; do n=`echo $line|awk 'BEGIN{FS=",";OFS="\t"}{print $1}'`; a=`echo $line|awk 'BEGIN{FS=",";OFS="\t"}{print $3}'`; h=`echo $line|awk 'BEGIN{FS=",";OFS="\t"}{print $15}'`;o=`echo $line|awk 'BEGIN{FS=",";OFS="\t"}{print $5}'`; s=`echo $line|awk 'BEGIN{FS=",";OFS="\t"}{print $8}'`; t=`echo $line|awk 'BEGIN{FS=",";OFS="\t"}{print $7}'`; if [ $d = $n ];then  echo -e "Dear $h, \n\nPlease help to install computer for $a ($n) from $t depoartment before $o. His/Her TL's name is $s."| mail -s "$h, please help to install Computer's for $a before $o" -r "Michael_Wang@resourcepro.com.cn" itsupport@resourcepro.com.cn; else continue; fi; done
