```
kubectl create namespace webhook
kubectl --namespace=webhook create -f replicationcontroller.yaml
kubectl --namespace=webhook create -f service.yaml
```
