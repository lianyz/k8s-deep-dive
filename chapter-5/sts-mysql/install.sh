k delete ns lianyz
k delete pv sts-pv1
k delete pv sts-pv2
k delete pv sts-pv3

k create ns lianyz
ka cm.yaml
ka pv1.yaml
ka pv2.yaml
ka pv3.yaml
ka svc.yaml
ka sts.yaml
ka pod-mysql-client.yaml
