#!/bin/bash

WsRootDir=`pwd`
export USER=`whoami`
export PATH=~/bin:$PATH
PRO_PATH=$WsRootDir/P118F_Factory
CPUCORE=8
D_TIME=`date +%Y%m%d`
Version1="TYC-P118F-U000C_V1.0B13_SMT_L0801"
Version2="tye100.1.00.00.13_SMT_L0801"

function main()
{
    if [ ! -d $PRO_PATH/.repo ];then
        echo "不存在"
        mkdir $PRO_PATH
        cd $PRO_PATH
            pull_code
            original_build
            make_NOHLOS
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_SDM450_Factory_QFIL.zip $Version1
            upload_version            
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            #rm -rf out
            #repo forall -c 'git clean -fd;git reset --hard HEAD;git status'
            rm -rf *
			cd ./wind
                old_commitID=$(git log -1 | grep "commit" | awk '{print $2}')
            cd -
            repo sync -cj4
			cd ./wind
                git pull 
                new_commitID=$(git log -1 | grep "commit" | awk '{print $2}')
            cd -
			if [ $old_commitID == $new_commitID ];then
                echo "没有人提交"
                exit
            else
				repo start Stable_P118F_Factory_BRH --all
				original_build
				make_NOHLOS
			fi
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_SDM450_Factory_QFIL.zip $Version1
            upload_version
        cd -
    fi
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    #"修改dailybuild版本号"
    sed -i "s/INVER=.*/INVER=$Version1/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    sed -i "s/OUTVER=.*/OUTVER=$Version2/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    ./quick_build.sh P118F userdebug fc new factory
}

function pull_code()
{
    echo "####################### pull code start #######################"
    #--no-repo-verify:不进行校验
    repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_PSW/Manifest -m manifest.xml -b Stable_P118F_Factory_BRH --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference="/home/itadmin/mirror/P118F_MIRROR" 
    
    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path ssh://$USER@10.0.30.10:29418/$PLALFORM_LIBRARY  is right?"
    exit 0
    fi
    
    sed -i "s/itadmin\@//g" ./.repo/manifest.xml
    
    
    #更新代码，创建分支
    repo sync
    repo start Stable_P118F_Factory_BRH --all
    echo "####################### pull code end #########################"
}

function make_NOHLOS(){
    cd NOHLOS/
    ./build_n.sh all fc 2>&1 | tee build_nohlos.log
    ./cpn P118F
    echo "切片完成"
}

function upload_version(){
    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\P118F\P118F_Factory_dailybuild;lcd $PRO_PATH/NOHLOS/out;put  P118F_Factory_$D_TIME.zip"
}
#####################
main 
