# 容器技术基础

## 查看docker在Cgroups文件系统下CPU等子系统的限制的信息
```
/sys/fs/cgroup/cpu/docker/<longid>/在 cgroup v1 上，cgroupfs驱动程序
/sys/fs/cgroup/cpu/system.slice/docker-<longid>.scope/在 cgroup v1 上，systemd驱动程序
/sys/fs/cgroup/docker/<longid/>在 cgroup v2 上，cgroupfs驱动程序
/sys/fs/cgroup/system.slice/docker-<longid>.scope/在 cgroup v2 上，systemd驱动程序
```
[为什么docker 没有 /sys/fs/cgroup/cpu/docker这个目录](https://blog.csdn.net/fly910905/article/details/123718418)

## 查看cgroup版本及驱动程序
```
$ docker info
Client:
 Context:    default
 Debug Mode: false

Server:
 Containers: 131
  Running: 98
  Paused: 0
  Stopped: 33
 Images: 31
 Server Version: 20.10.7
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 
 runc version: 
 init version: 
 Security Options:
  apparmor
  seccomp
   Profile: default
 Kernel Version: 5.15.0-41-generic
 Operating System: Ubuntu 20.04.3 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 4
 Total Memory: 2.912GiB
 Name: k8smaster
 ID: KVUB:2P36:U7BP:M2Y5:3PO6:HSAO:2JBK:VC2K:F5FA:CEST:R7TR:TFBL
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Registry Mirrors:
  https://pme3c7qu.mirror.aliyuncs.com/
 Live Restore Enabled: false
```


# 安装 ubuntu22.04 操作系统

## 修改root密码

1. 默认root密码是随机的，即每次开机都有一个新的root密码。我们可以在终端输命令 sudo passwd，然后输入当前用户的密码，然后按enter键
2. 终端会提示我们输入新的密码并确认，此时的密码就是root新密码。修改成功后，输入命令 su root，再输入新的密码就ok了


## 修改hostname

vim /etc/hostname


# Kubernetes集群搭建和配置

## 设置源

``` shell
# 配置apt
apt-get update && apt-get install -y apt-transport-https
# 配置key
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
# 添加阿里云镜像
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
# 更新源
apt-get update
```

# Kubernetes编排原理

## Pod内的容器共享 PID Namespace

``` sh
k create -f nginx.yaml
```

```
$ k attach -it nginx -c shell
/ # ps ax
PID   USER     TIME  COMMAND
    1 65535     0:00 /pause
    7 root      0:00 nginx: master process nginx -g daemon off;
   39 101       0:00 nginx: worker process
   40 101       0:00 nginx: worker process
   41 101       0:00 nginx: worker process
   42 101       0:00 nginx: worker process
   43 root      0:00 sh
   49 root      0:00 ps ax

```
## 安装Nginx Ingress

```
root@k8smaster:~/k8s-deep-dive# k apply -f deploy-nginx-ingress.yml 
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
serviceaccount/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
configmap/ingress-nginx-controller created
service/ingress-nginx-controller created
service/ingress-nginx-controller-admission created
deployment.apps/ingress-nginx-controller created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created

```



# 常见问题

## k8s.gcr.io镜像无法拉取问题(Google Container Registry)

将
k8s.gcr.io/serve_hostname
修改为
docker.io/mirrorgooglecontainers/serve_hostname:latest

