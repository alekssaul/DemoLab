# DemoLab Hosted on GCP

## Requirements

- Google Cloud Platform Account
- gcloud utility need to exist in the system
- create a Project in Google Compute Engine
- ~2 GB free space as we need to pull down latest K8s release

## Getting Started

`infra_gcp_up.sh` script uses Google's way of setting up Kubernetes cluster with environmental variables provided to facilitate installation of CoreOS and sizing decisions based on my preferances

### Start Cluster

```
infra_gcp_up.sh
```

### Kill Cluster

Not ready yet

## "By Hand"
```
gcloudzone=$(gcloud config list | grep zone | awk '{print $3}')
export KUBE_GCE_ZONE=$gcloudzone
export KUBE_OS_DISTRIBUTION=coreos
export KUBE_GCE_MASTER_PROJECT=coreos-cloud
export KUBE_GCE_MASTER_IMAGE=$(gcloud compute images list | grep coreos | grep alpha | awk '{print $1}')
export ENABLE_NODE_AUTOSCALER=false
export AUTOSCALER_MAX_NODES=5
export KUBE_ENABLE_CLUSTER_MONITORING=googleinfluxdb
export KUBECTL_BIN=/opt/kubernetes/server/bin/kubectl

curl -sS https://get.k8s.io | bash

```