# DemoLab
SE Demo Lab as Code

* Setup gcloud settings

```shell
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
```
