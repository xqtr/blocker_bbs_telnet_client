#!/bin/bash

curl https://www.telnetbbsguide.com/lists/download-list/ > temp.htm
file="$(cat temp.htm | grep "/bbslist/" -m 1 | cut -d "\"" -f2)"
rm temp.htm
mkdir temp
cd temp
wget "https://www.telnetbbsguide.com$file"
file="$(echo $file | cut -d "/" -f3)"
unzip $file
file="$(ls short*)"
cat $file | tail -n +52 | head -n -7 | sed 's/\*/ /g' > tmplist.txt
counter=1
while read -r line; do
  name="$(echo ${line:0:39})"
  addr="$(echo ${line:41})"
  echo "[$counter]" >> blocker_telnetbbs.bbs
  echo "name=$name" >> blocker_telnetbbs.bbs
  echo "address=$addr" >> blocker_telnetbbs.bbs
  echo "user=" >> blocker_telnetbbs.bbs
  echo "pass=" >> blocker_telnetbbs.bbs
  echo "statusbar=1" >> blocker_telnetbbs.bbs
  echo "music=1" >> blocker_telnetbbs.bbs
  echo "last=0" >> blocker_telnetbbs.bbs
  echo "added=0" >> blocker_telnetbbs.bbs
  echo "lastedit=0" >> blocker_telnetbbs.bbs
  echo "calls=0" >> blocker_telnetbbs.bbs
  echo "sysop=" >> blocker_telnetbbs.bbs
  echo "software=" >> blocker_telnetbbs.bbs
  echo "comment=" >> blocker_telnetbbs.bbs
  echo "rating=0" >> blocker_telnetbbs.bbs
  echo "validated=0" >> blocker_telnetbbs.bbs
  echo "flags=MB" >> blocker_telnetbbs.bbs
  echo " " >> blocker_telnetbbs.bbs
 let counter++
done < tmplist.txt

mv blocker_telnetbbs.bbs ..
cd ..
rm ./temp/*
rmdir temp