```
kubectl create namespace webhook
export KUBECONFIG=$HOME/.kube/config
kubectl --namespace=webhook create configmap kubeconfig --from-file=$KUBECONFIG
kubectl --namespace=webhook create -f ./manifests/replicationcontroller.yaml
kubectl --namespace=webhook create -f ./manifests/service.yaml
```
