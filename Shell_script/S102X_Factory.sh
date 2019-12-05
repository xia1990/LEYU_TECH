#!/bin/bash

WsRootDir=`pwd`
export USER=`whoami`
PRO_PATH=$WsRootDir/S102X_Factory
CPUCORE=8
D_TIME=`date +%Y%m%d`
Version="IFL-S102X-U100C_V1.0B03_0903"

function main()
{
    if [ ! -d $PRO_PATH/.repo ];then
        echo "不存在"
        mkdir $PRO_PATH
        cd $PRO_PATH
            pull_code
            original_build
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_S102X_32_Factory_QFIL.zip $Version.zip
            upload_version
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            rm -rf *
            repo sync -cj4
	    repo start Stable_Factory32_BRH --all
            original_build
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_S102X_32_Factory_QFIL.zip $Version.zip
            upload_version
        cd -
    fi
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    sed -i "s/INVER=.*/INVER=$Version/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    sed -i "s/OUTVER=.*/OUTVER=$Version/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    #sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    ./quick_build.sh S102X_32 debug new fc NOHLOS
}

function pull_code()
{
    
    #--no-repo-verify:不进行校验
    repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_S102X_PSW/Manifest -m manifest.xml -b Stable_Factory32_BRH --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference="/home/itadmin/mirror/S102X_MIRROR"
    
    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path ssh://$USER@10.80.30.10:29418/$PLALFORM_LIBRARY  is right?"
        exit 0
    else
        sed -i 's/itadmin/'"$USER"'/' ./.repo/manifest.xml
    fi
    
    #更新代码，创建分支
    repo sync -cj4
    repo start Stable_Factory32_BRH --all
    cd $PRO_PATH/wind
        git pull --rebase
    cd -
    echo "####################### pull code end #########################"
}

function make_NOHLOS(){
    cd $PRO_PATH/NOHLOS/
        echo "start to build NOHLOS"
        ./build_n.sh all fc
        ./cpn
    cd -
}

function upload_version(){
        smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "1_正式软件版本\SDM450\S102X\生产版本\6_MP_SMT;mkdir $Version;cd $Version;lcd $PRO_PATH/NOHLOS/out;put $Version.zip"
}
################################
main
