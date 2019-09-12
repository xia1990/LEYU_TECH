#!/bin/bash
#添加远程连接地址

namearray=($(repo list | awk '{print $3}'))
patharray=($(repo list | awk '{print $1}'))

#得到仓库的个数
name_length=${#namearray[@]}
path_length=${#namearray[@]}

echo $name_length
echo $path_length


for i in `seq 0 $(($name_length-1))`
do
    name=${namearray[$i]} 
    path=${patharray[$i]}
    pushd $path > /dev/null
        git remote add origin2 ssh://10.0.30.10:29418/LNX_LA_SDM450_S102X_PSW/$name
        echo $path-------"添加远程仓库成功"
    popd > /dev/null
done
