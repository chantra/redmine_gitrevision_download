#!/bin/bash

dir=`dirname $0`
redmine_dir=$dir'/../../../'
lang1='lang'
lang2='config/locales'

ls -1 $redmine_dir/$lang2 | grep -v en.yml | while read line
do
  lang=`expr "$line" : "\(.*\).yml"`
  cp $lang2/en.yml $lang2/$line
  cp $lang1/en.yml $lang1/$line
  if [ `expr "$lang" : "\(.*\)-\(.*\)"` ]
  then
    sed -i "s/^en:/\x22${lang}\x22:/" $lang2/$line  
  else
    sed -i "s/^en:/${lang}:/" $lang2/$line  
  fi
done
