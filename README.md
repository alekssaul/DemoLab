# DemoLab
Demo Lab as Code

export KUBE_GCE_ZONE=us-east1-b


export KUBE_OS_DISTRIBUTION=coreos
export KUBE_GCE_MASTER_PROJECT=coreos-cloud
export KUBE_GCE_MASTER_IMAGE=$(gcloud compute images list | grep coreos | grep alpha | awk '{print $1}')
export ENABLE_NODE_AUTOSCALER=false
export AUTOSCALER_MAX_NODES=5
export ENABLE_CLUSTER_MONITORING=googleinfluxdb
export ENABLE_CLUSTER_DNS=true
export DNS_DOMAIN=tectonic.local

./cluster/kube-up.sh

kubectl create namespace tectonic-system
kubectl --namespace=tectonic-system create -f https://tectonic.com/enterprise/docs/latest/deployer/files/tectonic-console.yaml

Install Pull Secret
kubectl --namespace=tectonic-system create -f coreos-pull-secret.yml

View Tectonic Console
kubectl  --namespace=tectonic-system get pods -l tectonic-app=console -o template --template="{{range.items}}{{.metadata.name}}{{end}}" | xargs -I{} kubectl port-forward {} 9000


