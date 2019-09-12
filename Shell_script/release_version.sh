#!/bin/bash

PATHROOT=`pwd`
PROJECT="SWAI_PAD"

pushd $PATHROOT/out/target/product/"SWAI_PAD"
    if [ -d "release_out" ];then
        cp *.img release_out
        cp *.mbn release_out
    else
        mkdir release_out
        cp *.img release_out 
        cp *.mbn release_out
        zip -r -9 release_out.zip ./release_out
    fi
popd
