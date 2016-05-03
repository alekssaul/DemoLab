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

*** As of Kubernetes 1.2.3 there is an issue with python being referenced to incorrect python image; https://github.com/kubernetes/kubernetes/commit/32426d6e97a641182163d667f980993ea01b2f8f fixed it.. may need to manually change /opt/kubernetes/saltbase/salt/kube-addons/kube-addons.sh to use 
```local -r PYTHON_IMAGE=gcr.io/google_containers/python:v1``` instead of ```local -r PYTHON_IMAGE=python:2.7-slim-pyyaml``` or built kubernetes from master
