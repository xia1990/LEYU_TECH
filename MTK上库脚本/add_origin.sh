#!/bin/bash
#添加远程连接地址

namearray=($(cat project_name.txt))
patharray=($(cat project_path.txt))

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
        git remote add origin3 ssh://10.80.30.10:29418/$name
        echo $path-------"添加远程仓库成功"
    popd > /dev/null
done
