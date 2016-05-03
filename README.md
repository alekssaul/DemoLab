# DemoLab
SE Demo Lab as Code

* Setup gcloud settings

Setup Environmental variables for kubenernetes deployment settings

```shell
export KUBE_GCE_ZONE=us-east1-b
export KUBE_OS_DISTRIBUTION=coreos
export KUBE_GCE_MASTER_PROJECT=coreos-cloud
export KUBE_GCE_MASTER_IMAGE=$(gcloud compute images list | grep coreos | grep alpha | awk '{print $1}')
export ENABLE_NODE_AUTOSCALER=false
export AUTOSCALER_MAX_NODES=5
export KUBE_ENABLE_CLUSTER_MONITORING=googleinfluxdb
export KUBE_ENABLE_CLUSTER_DNS=true
export DNS_DOMAIN=tectonic.local
export KUBECTL_BIN=/opt/kubernetes/server/bin/kubectl
```

Deploy Kubernetes

``` shell
curl -sS https://get.k8s.io | bash
``` 

Test to make sure kubernetes nodes are available
``` shell 
kubectl get nodes 
```

vi /opt/kubernetes/saltbase/salt/kube-addons/kube-addons.sh