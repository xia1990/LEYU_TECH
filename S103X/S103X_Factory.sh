#!/bin/bash

WsRootDir=`pwd`
export USER=`whoami`
export PATH=~/bin:$PATH
PRO_PATH=$WsRootDir/S103X_Factory
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
            mv S103X_32_Factory_QFIL.zip S103X_Factory_$D_TIME.zip
            upload_version
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            #rm -rf out
            #repo forall -c 'git clean -fd;git reset --hard HEAD'
            rm -rf *
			cd ./wind
                old_commitID=$(git log -1 | grep "commit" | awk '{print $2}')
            cd -
            repo sync -j4
			cd ./wind
                git pull 
                new_commitID=$(git log -1 | grep "commit" | awk '{print $2}')
            cd -
            if [ $old_commitID == $new_commitID ];then
                echo "没有人提交"
                exit
            else
				repo start Stable_Factory32_BRH --all
				original_build
			fi
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv S103X_32_Factory_QFIL.zip S103X_Factory_$D_TIME.zip
            upload_version
        cd -
    fi
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    #"修改dailybuild版本号"
    DAILYBUILD_NUMBER=S103X_Factory_$D_TIME
    echo $DAILYBUILD_NUMBER
    sed -i "s/INVER=.*/INVER=$DAILYBUILD_NUMBER/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    #sed -i "s/OUTVER=.*/OUTVER=tye100.1.00.00.01/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    #sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/S102X_32/version
    ./quick_build.sh S102X_NA debug new fc NA
}

function pull_code()
{
    
    #--no-repo-verify:不进行校验
    repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_S102X_PSW/Manifest -m manifest.xml -b Stable_Factory32_BRH --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference=/home/gaoyuxia/mirror/S102X_MIRROR/
    
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
        ./cpn_na
    cd -
}

function upload_version(){
    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\S103X\S103X_Factory_dailybuild;lcd $PRO_PATH/NOHLOS/out;put S103X_Factory_$D_TIME.zip"
}
################################
main
