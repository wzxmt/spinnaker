# Spinnaker Installation Manual

目前spinnaker的安装大都采用halyard部署。使用halyard安装部署非常简单，如果您的网络允许部署起立更快！


## 安装说明(最新)

- 提前部署好S3存储（可以使用minio，提前部署好，注意更新tools/halyard.sh文件）

```
## Storage 配置基于minio搭建的S3存储
hal config storage s3 edit \
        --endpoint http://minio.idevops.site \
        --access-key-id AKIAIOSFODNN7EXAMPLE \
        --secret-access-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
        --bucket spinnaker \
        --path-style-access true --no-validate
hal config storage edit --type s3 --no-validate
```

- 如需自定义spinnaker域名，可以修改tools/halyard.sh

```
DECK_HOST="http://spinnaker.idevops.site"
GATE_HOST="http://spin-gate.idevops.site"
```

在[actions](https://github.com/zeyangli/spinnaker-cd-install/actions) 中获取最新的版本部署脚本文件。
将该文件上传到配置好了kubectl客户端的节点中。

```
unzip 1.23.6-Install-Script.zip  && cd 1.23.6
[root@master 1.23.6]# ls
GetImages.sh  halyard.sh  halyard.yaml  ingress.yaml  install.sh  tagfile.txt
[root@master 1.23.6]# tree
.
├── GetImages.sh     ## 可单独执行，遍历tagfile.txt进行镜像下载。
├── halyard.sh       ## Halyard初始化配置脚本。
├── halyard.yaml     ## Halyard容器方式部署时的配置文件。
├── ingress.yaml     ## Spinnaker 部署后的Ingress模板文件。
├── install.sh       ## Spinnaker 部署脚本。
└── tagfile.txt      ## 镜像标签文件（该文件的形成取决于bom版本文件中的定义，具体可以看actions过程）

0 directories, 6 files
```

在每个k8s node节点下载spinnaker部署时需要的docker镜像， 然后安装spinnaker。

```
[root@master 1.23.6]# sh install.sh
 [getimg -> install -> ingress = allinstall]

sh install.sh getimg    ## 下载镜像（提前配置好各node节点的免密）
sh install.sh install   ## 安装spinnaker
sh install.sh ingress   ## 创建ingress

```
验证pod运行状态

```
[root@master 1.23.6]# kubectl get pod -n spinnaker
NAME                                READY   STATUS    RESTARTS   AGE
spin-clouddriver-65c656b665-v9qgg   0/1     Running   0          36s
spin-deck-c74b79594-vbp2l           1/1     Running   0          34s
spin-echo-56bbbbd648-bj2ss          0/1     Running   0          36s
spin-front50-54894dd569-6p89d       0/1     Running   0          31s
spin-gate-5798654745-4fzkw          0/1     Running   0          35s
spin-igor-68f6bfdcbc-zbhcq          0/1     Running   0          33s
spin-orca-5547d664b8-pj8tw          0/1     Running   0          32s
spin-redis-6d85585fd7-d6jzx         1/1     Running   0          34s
spin-rosco-56c56bb968-vmfr8         0/1     Running   0          31s
```

## Spinnaker版本更新
注意：现在已经在actions中配置ci，大部分步骤都是自动完成的。需要提前将您当前spinnaker版本的boms文件（~/.hal/.boms）打包上传到代理库updates目录中哦！

使用github actions 自动化获取版本文件，获取gcr.io镜像然后更名上传到阿里云仓库中。最后会生成一个制品`version-install-script`，里面包含镜像tag文件和下载镜像的脚本。
(图片如果加载不出来，可以直接在Actions中查看最新的流水线中获取哦)

然后手动获取服务版本分支中的配置文件，（此步骤已经在ci中实现，无需手动，直接下载actions制品即可）


最后手动发布。

```
unzip 1.19.14-Image-Script.zip
cd 1.19.14

rm -fr ~/.hal/.boms/
mv .boms/ ~/.hal/
chmod 777 -R ~/.hal/*
 
docker exec -it halyard bash
hal config version edit --version local:1.19.14 --no-validate
hal deploy apply --no-validate
```

回滚
```
hal config version edit --version local:1.19.4 --no-validate
hal deploy apply --no-validate
```


