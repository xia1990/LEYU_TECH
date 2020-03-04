#!/bin/bash
function log(){
    local -r level="$1"
    local -r string="$2"
    local -r time_now=$(date +%Y-%m-%d' '%H:%M:%S)
    case "$level" in  
       "error") echo -e "\e[31m$time_now ERROR: $string\e[0m" ;;
       "info") echo "$time_now INFO: $string" ;;
       "good") echo -e "\e[32m$time_now GOOD: $string\e[0m" ;;
       "notice") echo -e "\e[34m$time_now NOTICE: $string\e[0m" ;;
    esac    
}

function list_branch(){
    local -r local_project="$1"
    array=($(eval echo \${${local_project}_branch_list[@]}))
    for branch_name in "${array[@]}"
    do
        echo "$branch_name"
    done
}

function set_project_flag_url_mirror(){
    local -r local_project="$1"
    local -r local_branch="$2"
    array=($(eval echo \${${local_project}_branch_list[@]}))
    for branch_name in "${array[@]}"
    do
        if [ "$local_branch" == "$branch_name" ]
        then
            branch_flag="true"
        fi
    done
    [ "$branch_flag" == "false" ] && log "error" "$local_branch BRANCH not exist in E300L"
    code_url=$(eval echo \$${local_project}_url)
    code_mirror=$(eval echo \$${local_project}_mirror)
}

function parse_args(){
    project="$1"
    branch="$2"

    project_list=("E300L" "A305" "A306" "A307" "A308" "E26XL")

    E300L_url="ssh://gerritmaster.wind-mobi.com:29418/MSM89XX_P_CODE_SW3/manifest"
    A305_url="ssh://gerritmaster.wind-mobi.com:29418/MSM89XX_P_CODE_SW3/manifest"
    A306_url="ssh://gerritmaster.wind-mobi.com:29418/MSM89XX_P_CODE_SW3/manifest"
    A307_url="ssh://gerritmaster.wind-mobi.com:29418/MSM89XX_P_CODE_SW3/manifest"
    A308_url="ssh://gerritmaster.wind-mobi.com:29418/MSM89XX_P_CODE_SW3/manifest"
    E26XL_url="ssh://gerritmaster.wind-mobi.com:29418/GR6750_66_A_N_ASUS_SW3/tools/manifest"

    E300L_mirror="/EXCHANGE/mirror/MSM89XX_P_MIRROR/"
    A305_mirror="/EXCHANGE/mirror/MSM89XX_P_MIRROR/"
    A306_mirror="/EXCHANGE/mirror/MSM89XX_P_MIRROR/"
    A307_mirror="/EXCHANGE/mirror/MSM89XX_P_MIRROR/"
    A308_mirror="/EXCHANGE/mirror/MSM89XX_P_MIRROR/"
    E26XL_mirror="/EXCHANGE/mirror/E26X_MIRROR_REPO/"

    E300L_branch_list=("qualcomm" "E300L_DEV_BRH" "E300L_FACTORY_BRH")
    A305_branch_list=("qualcomm" "A305_DEV_BRH")
    A306_branch_list=("qualcomm" "A306_DEV_BRH" "A306_FACTORY_BRH")
    A307_branch_list=("qualcomm")
    A308_branch_list=("qualcomm")
    E26XL_branch_list=("master" "E26XL_DEV_BRH")

    if [[ "$project" == "" || "$branch" == "" ]]
    then
        echo ""
        for project_name in "${project_list[@]}"
        do
            echo "$project_name"
        done
        log "notice" "请输入项目名称:"
        read -t 10 project
        [ "$project" == "" ] && log "error" "timeout 20s" && exit 1

        echo ""
        list_branch "$project"
        log "notice" "请输入分支名称:"
        read -t 20 branch
     fi



    project_flag="false"
    branch_flag="false"
    if [[ "$project" != "" || "$branch" != "" ]]
    then
        for project_name in "${project_list[@]}"
        do
             if [ "$project" == "$project_name" ]
             then
                project_flag="true"
                break
             fi
        done
        [ "$project_flag" == "false" ] &&  log "error" "$project not exist!!!!" && exit 1

        if [ "$project_flag" == "true" ]
        then
            set_project_flag_url_mirror "$project" "$branch"
        fi
    fi

}

function download_code(){
    [ -d "$code_mirror" ] || log "notice" "请联系SCM部署mirror"
    repo init -u "$code_url"  -m "$branch".xml --reference="$code_mirror"
    repo sync -cj4
	repo forall -c 'git reset --hard'
    repo start "$branch" --all
}
################
parse_args "$@"
download_code 
