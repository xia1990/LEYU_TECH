#!/bin/bash
#提交客户代码(此脚本只限于P118F使用，全部同步)
#此脚本需要放在代码根目录下执行

PATHROOT=`pwd`
PROJECT=P118F
COMMIT_ID="$1"
describe="$2"


function reset_code(){
    pushd $PATHROOT/wind
        git pull --rebase
        git reset --hard $COMMIT_ID
    popd
}


function commit_code(){
    pushd $PATHROOT
        pushd ../251_P118F/wind/
            git pull --rebase
        popd
        rsync -avzp --exclude ".git" --delete ./wind/ ../251_P118F/wind/
        pushd $PATHROOT/wind
            file=$(git diff $COMMIT_ID $COMMIT_ID^ --name-status | awk '{print $2}')
            echo -e "\e[31m $file \e[0m"
        popd

        pushd ../251_P118F/wind/
            git add $file
            #定义提交模板的信息
            message="[Subject]\n[$PROJECT]\n[Bug Number/CSP Number/Enhancement/New Feature]\nN/A\n[Ripple Effect]\nN/A\n[Solution]\nN/A\n[Project]\n[$PROJECT]\n\n\n"
            #提交信息
            commit_message=$(echo -e $message | sed "0,/\[$PROJECT\]/s/\[$PROJECT\]/&$describe/")
            
            #提交文件类型
            #TYPE=$(git status -s | awk '{print $1}')
            #提交文件列表
            #filelist=$(git status | grep "custom_files")

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
    pushd ../251_P118F/wind/
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
