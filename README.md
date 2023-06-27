# Spinnaker Installation Manual

### 01-使用Halyard获取bom版本文件

```
docker run -itd -p 8084:8084 -p 9000:9000 -p 8064:8064 --name halyard  us-docker.pkg.dev/spinnaker-community/docker/halyard:stable

docker exec -u root halyard hal version list
SPINNAKER_VERSION=1.26.7
docker exec -u root halyard hal version bom ${SPINNAKER_VERSION} -q -o yaml >${SPINNAKER_VERSION}.yml

mkdir -p .boms/bom ${SPINNAKER_VERSION}
```

### 02-获取gcr.io镜像

```
#docker run -it  --rm -v `pwd`/:/opt/ python /bin/bash
docker run -it  --rm -v `pwd`/:/opt/ registry.cn-shanghai.aliyuncs.com/spinnakercd/python:latest /bin/bash
pip install pyyaml
cd /opt && alias ll="ls -la"
SPINNAKER_VERSION=1.26.7
python3 tools/fileprocess.py ${SPINNAKER_VERSION}.yml  tagfile.txt .boms
cd .boms/rosco && tar zcvf packer.tar.gz packer --remove-file 
```

### 03-收集镜像tag文件和下载镜像的脚本

```
mv .boms tagfile.txt ${SPINNAKER_VERSION}
## install scripts files
sed -i "s/SPIN_VERSION/${SPINNAKER_VERSION}/g" tools/install.sh
sed -i "s/SPIN_VERSION/${SPINNAKER_VERSION}/g" tools/halyard.sh
cp tools/* ${SPINNAKER_VERSION}/
rm -fr rosco 
```

### 04-修改docker-registry

```
mv ${SPINNAKER_VERSION}.yml ${SPINNAKER_VERSION}/.boms/bom/
zip -r ${SPINNAKER_VERSION}-Install-Scripts.zip ${SPINNAKER_VERSION}
```

### 05-上传镜像

```
#登录仓库
docker login --username=wzxmt666 registry.cn-shanghai.aliyuncs.com

cat << 'EOF' >PushImages.sh
SPINNAKER_VERSION="1.31.0"
REGISTRY_URL="us-docker.pkg.dev/spinnaker-community/docker"
ALIYUN_REGISTRY_URL="registry.cn-shanghai.aliyuncs.com/spinnakercd"

docker pull us-docker.pkg.dev/spinnaker-community/docker/halyard:stable
docker tag us-docker.pkg.dev/spinnaker-community/docker/halyard:stable registry.cn-shanghai.aliyuncs.com/spinnakercd/halyard:${SPINNAKER_VERSION}
docker push registry.cn-shanghai.aliyuncs.com/spinnakercd/halyard:${SPINNAKER_VERSION}

for n in `cat tagfile.txt`
do
   docker pull ${REGISTRY_URL}/$n
   docker tag  ${REGISTRY_URL}/$n ${ALIYUN_REGISTRY_URL}/$n
   docker push ${ALIYUN_REGISTRY_URL}/$n
done
EOF
sh PushImages.sh
```
