#!/bin/bash
#上库文档

PATHROOT=`pwd`

repo list | awk '{print $3}' > project_name.txt
repo list | awk '{print $1}' > project_path.txt


function create_project(){
    pushd $PATHROOT
        for i in `cat project_name.txt`
        do
            ssh -p 29418 10.0.30.10 gerrit create-project LNX_LA_SDM450_S102X_PSW/$i -t FAST_FORWARD_ONLY -p Privilege/test
            if [ $? == 0 ];then
                echo $i"仓库创建完成"
            fi
        done
    popd    
}


function add_origin(){
    pushd $PATHROOT
        namearray=$(repo list | awk '{print $3}')
        patharray=$(repo list | awk '{print $1}')
        namelength=${#namearray[@]}
        pathlength=${#patharray[@]}

        for m in `seq 0 $(($namelength-1))`
        do
            name=${namearray[$m]}
            path=${patharray[$m]}

            pushd $path > /dev/null
                git remote add origin2 ssh://10.0.30.10:LNX_LA_SDM450_S102X_PSW/$name
            popd > /dev/null
        done
    popd
}


function push_project(){
    pushd $PATHROOT
        for n in `cat project_path.txt`
        do
            pushd $n > /dev/null
                git push origin master:master
            popd > /dev/null
        done
    popd
}


function main(){
    create_project
    add_origin
    push_project
}

#################### MAIN #####################
main "$#"
