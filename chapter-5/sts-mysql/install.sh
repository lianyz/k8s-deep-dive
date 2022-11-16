kubectl delete ns lianyz
kubectl delete pv sts-pv1
kubectl delete pv sts-pv2
kubectl delete pv sts-pv3

rm -rf /root/nfsclient/www1/mysql
rm -rf /root/nfsclient/www2/mysql
rm -rf /root/nfsclient/www3/mysql


kubectl create ns lianyz
kubectl cm.yaml
kubectl apply -f pv1.yaml
kubectl apply -f pv2.yaml
kubectl apply -f pv3.yaml
kubectl apply -f svc.yaml
kubectl apply -f sts.yaml
kubectl apply -f pod-mysql-client.yaml
