#!/bin/bash

WsRootDir=`pwd`
export USER=`whoami`
export PATH=~/bin:$PATH
PRO_PATH=$WsRootDir/P118F_Master
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
            make_NOHLOS
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_SDM450_QFIL.zip P118F-$D_TIME.zip
            upload_version
        cd -
    else
        echo "存在"
        cd $PRO_PATH
            #rm -rf out
            #repo forall -c 'git clean -fd;git reset --hard HEAD;git status'
            rm -rf *
            repo sync -cj4 -f
            cd $PRO_PATH/wind
                git checkout .
                git pull --rebase > log.txt
                if [ "$?" -ne 0 ];then
                    git pull --rebase
                fi
            cd -                       
			repo start master --all
			original_build
			make_NOHLOS
        cd -
        cd $PRO_PATH/NOHLOS/out
            mv FlashPackage_SDM450_QFIL.zip P118F-$D_TIME.zip
            upload_version
        cd -
    fi
    
}

function original_build()
{
    sed -i 's/CPUCORE=8/CPUCORE=32/' $PRO_PATH/quick_build.sh
    #"修改dailybuild版本号"
    DAILYBUILD_NUMBER=P118F_Master_$D_TIME
    echo $DAILYBUILD_NUMBER
    sed -i "s/INVER=.*/INVER=$DAILYBUILD_NUMBER/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    sed -i "s/OUTVER=.*/OUTVER=tye100.1.00.00.01/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    #sed -i "s/W95M01A2-2/W95M01A3-3/" $PRO_PATH/wind/custom_files/device/qcom/P118F/version
    ./quick_build.sh P118F userdebug fc new 
}

function pull_code()
{
    echo "####################### pull code start #######################"
    #--no-repo-verify:不进行校验
    repo init -u ssh://10.80.30.10:29418/LNX_LA_SDM450_PSW/Manifest -m manifest.xml -b master --repo-url=ssh://10.80.30.10:29418/Tools/Repo --no-repo-verify --reference="/home1/jinlujiao/mirror/P118F_MIRROR/"
    
    if [ ! -f ./.repo/manifest.xml ] ;then
        echo "repo init failed"
        echo "check repo path ssh://$USER@10.0.30.10:29418/LNX_LA_SDM450_PSW  is right?"
    exit 0
    fi
    
    sed -i "s/itadmin\@//g" ./.repo/manifests/manifest.xml
    
    
    #更新代码，创建分支
    repo sync -cj4
    repo start master --all
    echo "####################### pull code end #########################"
}

function make_NOHLOS(){
    cd NOHLOS/
    ./build_n.sh all fc 2>&1 | tee build_nohlos.log
    ./cpn P118F
    echo "切片完成"
}

function upload_version(){
	cd $PRO_PATH/NOHLOS/out
		smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\P118F\dailybuild;lcd $PRO_PATH/NOHLOS/out;put  P118F-$D_TIME.zip"
	cd -
}
#####################
main 
