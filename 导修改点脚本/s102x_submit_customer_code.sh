#!/bin/bash
#提交客户代码(此脚本只限于S102X使用，全部同步)
#此脚本需要放在代码根目录下执行

PATHROOT=`pwd`
PROJECT=S102X
#要回退到的commitid
COMMIT_ID="$1"
#提交信息
describe="$2"


function reset_code(){
    pushd $PATHROOT/wind
        git pull --rebase
        git pull origin master
        git reset --hard $COMMIT_ID
    popd
}


function commit_code(){
    pushd $PATHROOT
        pushd ../S102X_251/wind/
            git pull --rebase
        popd
        rsync -avzp --exclude ".git" --delete ./wind/ ../S102X_251/wind/ > /dev/null
        #得到要提交的文件
        pushd $PATHROOT/wind
            #file=$(git log $COMMIT_ID -1 | grep "custom_files" | awk '{print $2}')
            file=$(git diff $COMMIT_ID $COMMIT_ID^ --name-status | awk '{print $2}')
            echo -e "\e[31m $file \e[0m"
        popd
        pushd ../S102X_251/wind/
            git add $file
            #定义提交模板的信息
            message="[Subject]\n[$PROJECT]\n[Bug Number/CSP Number/Enhancement/New Feature]\nN/A\n[Ripple Effect]\nN/A\n[Solution]\nN/A\n[Project]\n[$PROJECT]\n\n\n"
            #提交信息
            commit_message=$(echo -e $message | sed "0,/\[$PROJECT\]/s/\[$PROJECT\]/&$describe/")
            
            #提交文件类型
            #TYPE=$(git status -s | awk '{print $1}')
            #提交文件列表
            #filelist=$(git status | grep "custom_files")
            #echo -e "\e[34m $filelist \e[0m"

            #此处处理换行问题
            git commit -m """$commit_message

    $file"""
            git clean -fdx
            git reset --hard HEAD
            echo "y" | repo upload .
        popd
    popd
}

function review_code(){
    pushd ../S102X_251/wind/
        REVIEW_ID=$(git log -1 | grep "commit" | awk '{print $2}')
        ssh -p 29418 10.80.30.251 gerrit review $REVIEW_ID --code-review +2
        #ssh -p 29418 10.80.30.251 gerrit review $REVIEW_ID --submit
    popd
}


function main(){
    reset_code
    commit_code
    #review_code
}

################### MAIN ###################
main "$#"
