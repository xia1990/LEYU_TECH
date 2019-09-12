#!/bin/bash

PATHROOT=`pwd`

cd $PATHROOT

for i in `ls`
do
    if [ -d $i ];then
        cd $i
            repo sync -j4 -f
        cd -
    fi
done
