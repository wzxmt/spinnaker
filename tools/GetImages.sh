#!/bin/bash
S_REGISTRY="registry.cn-shanghai.aliyuncs.com/spinnakercd"
NODES="n1 n2"

## 下载镜像
function GetImages(){
    echo -e "\033[43;34m =====GetImg===== \033[0m"
    IMAGES=$( cat tagfile.txt)
    for image in ${IMAGES}
    do
        for node in ${NODES}
        do 
           echo  -e "\033[32m ${node} ---> pull ---> ${image} \033[0m"
           ssh ${node} "docker pull ${S_REGISTRY}/${image}"
        done
    done
    for node in ${NODES}
    do
       echo -e "\033[43;34m =====${node}===镜像信息===== \033[0m"
       ssh ${node} "docker images | grep 'spinnakercd' "
    done
}

GetImages
