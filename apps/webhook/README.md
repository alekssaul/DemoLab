```
kubectl create namespace webhook
export KUBECONFIG=$HOME/.kube/config
kubectl --namespace=webhook create configmap kubeconfig --from-file=$KUBECONFIG
kubectl --namespace=webhook create -f replicationcontroller.yaml
kubectl --namespace=webhook create -f service.yaml
```
