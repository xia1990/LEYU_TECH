#!/bin/bash

WsRootDir=`pwd`
export USER=`whoami`
export PATH=~/bin:$PATH
PRO_PATH=$WsRootDir/P118F_251
CPUCORE=8

D_TIME=`date +%Y%m%d`

function main()
{
    if [ ! -d $PRO_PATH/.repo ];then
        echo "不存在"
        mkdir $PRO_PATH
        cd $PRO_PATH
            pull_code
            original_build
            #make_NOHLOS
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_SDM450_QFIL.zip P118F_251_$D_TIME.zip
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            rm -rf out
            repo forall -c 'git clean -fd;git reset --hard HEAD;git status'
            repo sync -j4
            repo start master --all
            original_build
	        #make_NOHLOS
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_SDM450_QFIL.zip P118F_251_$D_TIME.zip
        cd -
    fi
    
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    #"修改dailybuild版本号"
    DAILYBUILD_NUMBER=P118F_251_$D_TIME
    echo $DAILYBUILD_NUMBER
    sed -i "s/INVER=.*/INVER=$DAILYBUILD_NUMBER/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    sed -i "s/OUTVER=.*/OUTVER=tye100.1.00.00.01/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    #sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    ./quick_build.sh P118F userdebug new fc
}

function pull_code()
{
    echo "####################### pull code start #######################"
    #--no-repo-verify:不进行校验
    repo init -u git@10.0.30.251:LNX_LA_SDM450_PSW/Manifest -m manifest.xml -b master 

    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path git@10.0.30.251:/$PLALFORM_LIBRARY  is right?"
    exit 0
    fi
    
    sed -i 's/git\@//g' ./.repo/manifests/manifest.xml
    sed -i 's/22/29418/g' ./.repo/manifests/manifest.xml
    
    
    #更新代码，创建分支
    repo sync
    repo start master --all
    echo "####################### pull code end #########################"
}

function make_NOHLOS(){
    cd NOHLOS/
    ./build_n.sh all fc 2>&1 | tee build_nohlos.log
    ./cpn P118F
    echo "切片完成"
}

#####################
main 
