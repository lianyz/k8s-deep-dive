# k8s在节点上的各个目录

1. Pod的Volume在宿主机上的目录
```
/var/lib/kubelet/pods/<Pod ID>/volumes/<vendor>~<driver>/<volume Name>
e.g. /var/lib/kubelet/pods/a2a653e5-d142-4f14-b1be-f0e390bf4a15/volumes/k8s~nfs/test
```

2. flexVolume存储插件的目录
```
/usr/libexec/kubernetes/kubelet-plugins/volume/exec/<vendor>~<driver>/<plugin-name>
e.g. /usr/libexec/kubernetes/kubelet-plugins/volume/exec/k8s-nfs/nfs
```

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

# 安装nfs server

## 安装nfs服务端

参考：
1. [How to Install and Configure an NFS Server on Ubuntu 20.04](https://linuxize.com/post/how-to-install-and-configure-an-nfs-server-on-ubuntu-20-04/)
2. [NFS permission denied](https://unix.stackexchange.com/questions/79172/nfs-permission-denied)
```
# apt update
# apt install nfs-kernel-server
# cat /proc/fs/nfsd/versions
-2 +3 +4 +4.1 +4.2
```

```
# mkdir -p /srv/nfs4/backups
# mkdir -p /srv/nfs4/www
```

```
# mkdir -p /opt/backups
# mkdir -p /var/www
```

```
# mount --bind /opt/backups /srv/nfs4/backups
# mount --bind /var/www     /srv/nfs4/www
```

to make the bind mounts permanent across reboots, edit the /etc/fstab file:

```
vim /etc/fstab
```

add the following lines:
```
/opt/backups   /srv/nfs4/backups    none   bind  0   0
/var/www       /srv/nfs4/www        none   bind  0   0
```

export the file systems
```
vim /etc/exports
```

add the following lines:（no_root_squash选项，让客户端拥有写权限）
```
/srv/nfs4         192.168.34.0/24(rw,sync,no_subtree_check,crossmnt,fsid=0)
/srv/nfs4/backups 192.168.34.0/24(ro,sync,no_subtree_check) 192.168.34.2(rw,sync,no_subtree_check)
/srv/nfs4/www     192.168.34.2(rw,sync,no_root_squash,no_subtree_check)
```

export the shares:
```
exportfs -ar
```

```
# exportfs -v
/srv/nfs4/backups  192.168.34.2(rw,wdelay,root_squash,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
/srv/nfs4/www 	   192.168.34.2(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
/srv/nfs4     	   192.168.34.0/24(rw,wdelay,crossmnt,root_squash,no_subtree_check,fsid=0,sec=sys,rw,secure,root_squash,no_all_squash)
/srv/nfs4/backups  192.168.34.0/24(ro,wdelay,root_squash,no_subtree_check,sec=sys,ro,secure,root_squash,no_all_squash)
```

## 安装nfs客户端

```
# apt update
# apt install nfs-common
```

create two new directories for the mount points:
```
mkdir -p /root/nfsclient/backups
mkdir -p /root/nfsclient/www
```

mount the exported file systems with the mount command
```
# mount -t nfs -o vers=4 192.168.34.2:/backups /root/nfsclient/backups
# mount -t nfs -o vers=4 192.168.34.2:/www /root/nfsclient/www
```

verify the remote file system are mounted successfully
```
# df -h | grep "/root/nfsclient"
192.168.34.2:/backups   29G   19G  8.8G  69% /root/nfsclient/backups
192.168.34.2:/www       29G   19G  8.8G  69% /root/nfsclient/www
```

to make the mounts permanent on reboot, edit the /etc/fstab file:

```
192.168.34.2:/backup  /root/nfsclient/backups  nfs  defaults,timeo=900,retrans=5,_netdev   0   0
192.168.34.2:/www     /root/nfsclient/www      nfs  defaults,timeo=900,retrans=5,_netdev   0   0 
```

# 存储原理

## flexVolume

将flexVoliume存储插件nfs拷贝到各节点的插件目录下，即/usr/libexec/kubernetes/kubelet-plugins/volume/exec/k8s~nfs，nfs的实现见[Github](https://github.com/kubernetes/examples/blob/master/staging/volumes/flexvolume/nfs)

执行以下命令安装pod
```
# k apply -f storage/pod-flexvolume.yaml
```

```
# k describe pod busybox -n lianyz
...
Events:
  Type     Reason                  Age                    From               Message
  ----     ------                  ----                   ----               -------
  Normal   Scheduled               7m13s                  default-scheduler  Successfully assigned lianyz/busybox to k8smaster
  Warning  FailedMount             3m18s (x4 over 4m57s)  kubelet            Unable to attach or mount volumes: unmounted volumes=[test], unattached volumes=[kube-api-access-5m5kd test]: failed to get Plugin from volumeSpec for volume "test" err=no volume plugin matched
  Warning  FailedMount             3m6s (x16 over 7m14s)  kubelet            Unable to attach or mount volumes: unmounted volumes=[test], unattached volumes=[test kube-api-access-5m5kd]: failed to get Plugin from volumeSpec for volume "test" err=no volume plugin matched
```

### no volume plugin matched问题解决方案
1. 通过apt install jq命令安装jq工具
2. 通过chmod 777 nfs将插件实现设置为可执行
3. 重启虚拟机节点

Pod启动成功
```
# k get po -n lianyz
NAME        READY   STATUS    RESTARTS       AGE
busybox     1/1     Running   0              30m
```

```
k exec -it busybox -n lianyz -- sh
/ # 
```

在容器中查看/data目录，挂载成功。

# 安装 ubuntu22.04 操作系统

## 修改root密码

1. 默认root密码是随机的，即每次开机都有一个新的root密码。我们可以在终端输命令 sudo passwd，然后输入当前用户的密码，然后按enter键
2. 终端会提示我们输入新的密码并确认，此时的密码就是root新密码。修改成功后，输入命令 su root，再输入新的密码就ok了


## 修改hostname

vim /etc/hostname


## 添加访问github的公私钥对

```
ssh-keygen -t rsa -C "lianyz"
$> Your identification has been saved in /root/.ssh/id_rsa.
$> Your public key has been saved in /root/.ssh/id_rsa.pub.
```

将公钥id_rsa.pub添加到你的github或者gitlab等仓库中,
打开公钥文件复制全文

```
vim /root/.ssh/id_rsa.pub
```
使用邮箱登录github，用户->setting -> SSH key 将公钥粘贴进去，起个容易识别的名字 title


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


### DNS解析

DNS 解析是通过 Kubernetes 集群中配置的 CoreDNS 完成的，kubelet 将每个 Pod 的 /etc/resolv.conf 配置为使用 coredns pod 作为 nameserver。我们可以在任何 Pod 中看到 /etc/resolv.conf 的内容，如下所示：

```
search hello.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.152.183.10
options ndots:5
```

复制
DNS 客户端使用此配置将 DNS 查询转发到 DNS 服务器， resolv.conf 是解析程序的配置文件，其中包含以下信息：

nameserver：DNS 查询转发到的服务地址，实际上就是 CoreDNS 服务的地址。
search：表示特定域的搜索路径，有趣的是 google.com 或 mrkaran.dev 不是 FQDN 形式的域名。大多数 DNS 解析器遵循的标准约定是，如果域名以 . 结尾（代表根区域），该域就会被认为是 FQDN。有一些 DNS 解析器会尝试用一些自动的方式将 . 附加上。所以， mrkaran.dev. 是 FQDN，但 mrkaran.dev 不是。
ndots：这是最有趣的一个参数，也是这篇文章的重点， ndots 代表查询名称中的点数阈值，Kubernetes 中默认为5，如果查询的域名包含的点 “.” 不到5个，那么进行 DNS 查找，将使用非完全限定名称，如果你查询的域名包含点数大于等于5，那么 DNS 查询默认会使用绝对域名进行查询。
ndots 点数少于 5个，先走 search 域，最后将其视为绝对域名进行查询；点数大于等于5个，直接视为绝对域名进行查找，只有当查询不到的时候，才继续走 search 域。



# 常见问题

## k8s.gcr.io镜像无法拉取问题(Google Container Registry)

将
k8s.gcr.io/serve_hostname
修改为
docker.io/mirrorgooglecontainers/serve_hostname:latest


