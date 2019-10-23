#!/bin/bash

WsRootDir=`pwd`
MY_NAME=`whoami`
PRO_PATH=$WsRootDir/S100X_Master
CPUCORE=8
D_TIME=`date +%Y%m%d`

function main()
{
    if [ ! -d $PRO_PATH ];then
        echo "不存在"
        mkdir $PRO_PATH
        cd $PRO_PATH
            pull_code
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            rm -rf out
            repo forall -c 'git clean -fd;git reset --hard HEAD;git status'
            repo sync -cj4
            original_build
        cd -
    fi
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    echo "修改dailybuild版本号"
    DAILYBUILD_NUMBER=S100X_Master_$D_TIME
    echo $DAILYBUILD_NUMBER
    sed -i 's/$BUILD_DISPLAY_ID/IFL_dailybuild_number/' $PRO_PATH/wind/custom_files/build/tools/buildinfo.sh
    sed -i "s/IFL_dailybuild_number/$DAILYBUILD_NUMBER/" $PRO_PATH/wind/custom_files/build/tools/buildinfo.sh
    ./quick_build.sh S100X new debug fc
}

function pull_code()
{
    repo init -u ssh://10.80.30.10:29418/LNX_LA_MSM8917_PSW/Manifest -m manifest.xml -b Stable_Factory_BRH --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify
    
    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path ssh://$USER@10.80.30.10:29418/$PLALFORM_LIBRARY  is right?"
    exit 0
    fi
    
    #修改.repo/manifest.xml，将itadmin替换为自己的名字
    sed -i 's/itadmin/'"$USER"'/' ./.repo/manifest.xml
    
    
    #更新代码，创建分支
    repo sync -cj4
    repo start Stable_Factory_BRH --all
    echo "####################### pull code end #########################"
}

###########################
main

