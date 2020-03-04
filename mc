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

function parse_args(){
    PROJECT="$1"
    BRANCH=

    PROJECT_LIST=(S102X M500N)
    if [ "$PROJECT" != "" ]
        then
            case "$PROJECT" in
            S102X)
                S102X_URL="ssh://10.0.30.10:29418/LNX_LA_MSM8917_S102X_PSW/Manifest"
                S102X_MIRROR="/EXCHANGE/mirror/S102X_MIRROR_REPO/"
                BRANCH=master
            ;;
            M500N)
                M500N_URL="ssh://10.0.30.10:29418/LNX_SDM710_M500N_R10/Manifest"
                M500N_MIRROR="/EXCHANGE/mirror/AIBG_MIRROR/M500N_MIRROR_REPO/"
                BRANCH=PSW
            ;;
            esac
    fi

    if [[ "$PROJECT" == "" || "$BRANCH" == "" ]]
    then
        echo ""
        for PROJECT_NAME in "${PROJECT_LIST[@]}"
        do
            echo "$PROJECT_NAME"
        done
        log "notice" "请输入项目名称:"
        read -t 10 PROJECT
        [ "$PROJECT" == "" ] && log "error" "timeout 20s" && exit 1

        echo ""
     fi



    PROJECT_flag="false"
    if [[ "$PROJECT" != "" || "$BRANCH" != "" ]]
    then
        for PROJECT_NAME in "${PROJECT_LIST[@]}"
        do
             if [ "$PROJECT" == "$PROJECT_NAME" ]
             then
                PROJECT_flag="true"
                break
             fi
        done
        [ "$PROJECT_flag" == "false" ] &&  log "error" "$PROJECT not exist!!!!" && exit 1

        if [ "$PROJECT_flag" == "true" ]
        then
            case "$PROJECT" in
            S102X)
                code_url="$S102X_URL"
                code_mirror="$S102X_MIRROR"
            ;;
            M500N)
                code_url="$M500N_URL"
                code_mirror="$M500N_MIRROR"
            ;;
            esac
        fi
    fi

}

function download_code(){
    [ -d "$code_mirror" ] || log "notice" "请联系SCM部署mirror"
    repo init -u "$code_url"  -m manifest.xml -b $BRANCH --reference="$code_mirror" --repo-url=ssh://10.0.30.10:29418/Tools/Repo --no-repo-verify
    sed  -i "s/itadmin\@//g" .repo/manifests/manifest.xml
    repo sync -cj4
    repo start "$BRANCH" --all
}

###########################################
parse_args "$@"
download_code
