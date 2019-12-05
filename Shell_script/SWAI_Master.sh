#!/bin/bash
. /etc/profile

WsRootDir=`pwd`
export USER=`whoami`
export PATH=~/bin:$PATH
PRO_PATH=$WsRootDir/SWAI_Master
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
            upload_version
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            #rm -rf out
            #repo forall -c 'git clean -fd;git reset --hard HEAD;git status'
            rm -rf *
            repo sync -cj4 -d -f
            cd ./wind
                git pull
            cd -
            repo start master --all
            original_build
        cd -
        cd $PRO_PATH/NOHLOS/out
            upload_version
        cd -
    fi
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    #"修改dailybuild版本号"

    DAILYBUILD_NUMBER=SWAI_PAD_Master_$D_TIME
    echo $DAILYBUILD_NUMBER
    sed -i "s/INVER=.*/INVER=$DAILYBUILD_NUMBER/" $PRO_PATH/wind/custom_files/device/qcom/SWAI_PAD/version
    #sed -i "s/OUTVER=.*/OUTVER=tye100.1.00.00.01/" $PRO_PATH/wind/custom_files/device/qcom/SWAI_PAD/version
    #sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/SWAI_PAD/version
    ./quick_build.sh SWAI_PAD userdebug new fc NOHLOS
}

function pull_code()
{
    repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_SWAI_PAD/Manifest -m manifest.xml -b master --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference="/home/gaoyuxia/mirror/SWAI_MIRROR/"
    
    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path ssh://$USER@10.80.30.10:29418/LNX_LA_SDM450_SWAI_PAD  is right?"
        exit 0
    fi
    
    sed -i "s/itadmin\@//g" ./.repo/manifest.xml
    
    
    #更新代码，创建分支
    repo sync -j4
    repo start --all
    cd $PRO_PATH/wind
        git pull --rebase
    cd -
    echo "####################### pull code end #########################"
}

function upload_version(){
    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\SWAI_PAD\dailybuild;lcd $PRO_PATH/NOHLOS/out;put SWAI_Master_$D_TIME.zip"
}

########################
main
