#!/bin/bash

for i in `cat project_path.txt`
do
    pushd $i
        git push origin3 master:master
    popd
done
