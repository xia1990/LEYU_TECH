#!/bin/bash


BATHROOT=`pwd`
D_TIME=`date +%Y%m%d`

function main(){
    rm -rf *.zip
    #scp -r gaoyuxia@10.80.30.11:/home/gaoyuxia/dailybuild/S103X_Master/S103X_Master/NOHLOS/out/S103X_Master_$D_TIME.zip .
    scp -r gaoyuxia@10.80.30.11:/home/gaoyuxia/workspace/workspace/S103X_Master/S103X_Master/NOHLOS/out/S103X_Master_$D_TIME.zip .
    #scp -r gaoyuxia@10.80.30.11:/home/gaoyuxia/dailybuild/S103X_Factory/S103X_Factory/NOHLOS/out/S103X_Factory_$D_TIME.zip .
    scp -r gaoyuxia@10.80.30.11:/home/gaoyuxia/workspace/workspace/S103X_Factory/S103X_Factory/NOHLOS/out/S103X_Factory_$D_TIME.zip .
    
    #scp -r jinlujiao@10.80.30.14:/home1/jinlujiao/dailybuild/P118F_Master/P118F_Master/NOHLOS/out/P118F-$D_TIME.zip .
    #scp -r jinlujiao@10.80.30.14:/home1/jinlujiao/dailybuild/P118F_Factory/P118F_Factory/NOHLOS/out/P118F_Factory_$D_TIME.zip .

    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\S103X\S103X_Factory_dailybuild;lcd $BATHROOT;put S103X_Factory_$D_TIME.zip"
    if [ $? == 0 ];then
        echo "-------------Put File Sucess------------"
    fi
    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\S103X\S103X_Master_dailybuild;lcd $BATHROOT;put S103X_Master_$D_TIME.zip"
    if [ $? == 0 ];then
        echo "-------------Put File Sucess------------"
    fi  

    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\P118F\dailybuild;lcd $BATHROOT;put P118F-$D_TIME.zip"
    if [ $? == 0 ];then
        echo "-------------Put File Sucess------------"
    fi  
    
    smbclient //10.80.10.2/人工智能bg软件部/ -U gaoyuxia%gyx@2019 -c "cd 2_临时软件版本\P118F\P118F-Factory-dailybuild;lcd $BATHROOT;put P118F_Factory_$D_TIME.zip"
    if [ $? == 0 ];then
        echo "-------------Put File Sucess------------"
    fi  
  
}

###############
main
