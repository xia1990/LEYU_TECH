#!/bin/bash
. /etc/profile

WsRootDir=`pwd`
export USER=`whoami`
export PATH=~/bin:$PATH
PRO_PATH=$WsRootDir/S102X_Master
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
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_S102X_32_SDM450_QFIL.zip S102X_32_$D_TIME.zip
            #upload_version
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            #rm -rf out
            #repo forall -c 'git clean -fd;git reset --hard HEAD;git status'
            cd ./.repo/manifests
                repo manifest -ro old.xml
            cd -
            rm -rf *
            repo sync -cj4 -d -f
            cd ./wind
                git pull 
            cd -
            repo start master_32 --all
            cd ./.repo/manifests
                repo manifest -ro new.xml
            cd -
            original_build
            fi
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_S102X_32_SDM450_QFIL.zip S102X_32_$D_TIME.zip
            #upload_version
        cd -
    fi
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    #"修改dailybuild版本号"
    DAILYBUILD_NUMBER=S102X_32_Master_$D_TIME
    echo $DAILYBUILD_NUMBER
    sed -i "s/INVER=.*/INVER=$DAILYBUILD_NUMBER/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    #sed -i "s/OUTVER=.*/OUTVER=tye100.1.00.00.01/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    #sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    ./quick_build.sh S102X_32 debug new fc NOHLOS
}

function pull_code()
{
    #repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_S102X_PSW/Manifest -m manifest.xml -b master_32 --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference="/EXCHANGE/mirror/AIBG_MIRROR/S102X_MIRROR_REPO/"
    repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_S102X_PSW/Manifest -m manifest.xml -b master_32 --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference="/home2/gaoyuxia2/mirror/S102X_MIRROR"
    
    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path ssh://$USER@10.80.30.10:29418/$PLALFORM_LIBRARY  is right?"
        exit 0
    fi
    
    sed -i "s/itadmin\@//g" ./.repo/manifest.xml
    
    
    #更新代码，创建分支
    repo sync -j4
    repo start master_32 --all
    cd $PRO_PATH/wind
        git pull --rebase
    cd -
    echo "####################### pull code end #########################"
}

function upload_version(){
    cd $PRO_PATH/NOHLOS/out
        smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\S102X\32位版本\32_dailybuild;lcd $PRO_PATH/NOHLOS/out;put S102X_32_$D_TIME.zip"
    cd -
}

########################
main
cd $PRO_PATH/.repo/manifests
    repo diffmanifests old.xml new.xml > log.txt
    if [ -s "log.txt" ];then
        echo "file is not empty,begin upload"
        upload_version
    else
        echo "文件为空"
        rm -rf log.txt
        exit 0
    fi
cd -
