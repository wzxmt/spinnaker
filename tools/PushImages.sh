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