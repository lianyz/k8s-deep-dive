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

```