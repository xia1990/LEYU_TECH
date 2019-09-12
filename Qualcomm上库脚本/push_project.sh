#!/bin/bash

for i in `cat project_path.txt`
do
    #echo $i
    pushd $i
        git push origin2 master:master
    popd
done
