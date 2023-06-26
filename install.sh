#!/bin/bash

VERSION="1.26.7"
S_REGISTRY="gcr.io/spinnaker-marketplace"
T_REGISTRY="registry.cn-beijing.aliyuncs.com/spinnaker-cd"
BOMS_DIR="/root/.hal/"
BOMS_FILR=".boms"
KUBE_DIR="/root/.kube/"
HALY_IMAGE="gcr.io/spinnaker-marketplace/halyard:1.32.0"
DECK_HOST="spinnaker.idevops.site"
GATE_HOST="spin-gate.idevops.site"
NODES="node01.zy.com node02.zy.com"

## 下载镜像
function GetImages(){
    echo -e "\033[43;34m =====GetImg===== \033[0m"

    IMAGES=$( cat tagfile.txt)
    for image in ${IMAGES}
    do
        for node in ${NODES}
        do
           echo  -e "\033[32m ${node} ---> pull ---> ${image} \033[0m"
           ssh ${node} "docker pull ${T_REGISTRY}/${image}"
           echo  -e "\033[32m ${node} ---> tag ---> ${image} \033[0m"
           ssh ${node} "docker tag ${T_REGISTRY}/${image} ${S_REGISTRY}/${image}"
        done
    done
    for node in ${NODES}
    do
       echo -e "\033[43;34m =====${node}===镜像信息===== \033[0m"
       ssh ${node} "docker pull registry.cn-beijing.aliyuncs.com/spinnaker-cd/redis-cluster:v2 "
       ssh ${node} "docker tag registry.cn-beijing.aliyuncs.com/spinnaker-cd/redis-cluster:v2 gcr.io/kubernetes-spinnaker/redis-cluster:v2"
       ssh ${node} "docker images | grep 'spinnaker-marketplace' "
    done

}

function Clean(){
    echo -e "\033[43;34m =====Clean===== \033[0m"
    rm  -r ${BOMS_DIR}/config ${BOMS_DIR}/default
}

## 安装
function Install(){
    echo -e "\033[43;34m =====Install===== \033[0m"
    [ -d ${BOMS_DIR} ] || mkdir ${BOMS_DIR}
    mv ${BOMS_FILR} ${BOMS_DIR}
    ls -a ${BOMS_DIR}
    chmod 777 -R ${BOMS_DIR}
    chmod 777 -R ${KUBE_DIR}

    docker run -d  \
    --name halyard   \
    -v ${BOMS_DIR}:/home/spinnaker/.hal \
    -v ${KUBE_DIR}:/home/spinnaker/.kube \
    -it ${HALY_IMAGE}

    sleep 5
    docker cp halyard.yaml halyard:/opt/halyard/config/halyard.yml
    docker stop halyard  &&  docker start halyard
    sleep 3
    docker ps | grep halyard
    sleep 5
    chmod +x halyard.sh
    docker cp halyard.sh halyard:/home/spinnaker/halyard.sh
    docker exec -it halyard ./home/spinnaker/halyard.sh
    sleep 5
    kubectl get pod -n spinnaker
    sleep 5
    kubectl get pod -n spinnaker
}

## Ingress
function Ingress(){
    echo -e "\033[43;34m =====Ingress===== \033[0m"
    sed -i "s/deck_domain/${DECK_HOST}/g" ingress.yaml
    sed -i "s/gate_domain/${GATE_HOST}/g" ingress.yaml
    cat ingress.yaml
    sleep 5
    kubectl create -f  ingress.yaml -n spinnaker
}


case $1 in
  getimg)
    GetImages
    ;;
 # clean)
 #   Clean
 #   ;;
  install)
    Install
    ;;
  ingress)
    Ingress
    ;;
  allinstall)
    Clean
    GetImages
    Install
    sleep 10
    Ingress
    ;;

  *)
    echo -e " [getimg -> install -> ingress = allinstall] "
    ;;
esac
