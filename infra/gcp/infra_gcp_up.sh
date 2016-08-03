#!/bin/bash

echo `date` - Starting Kubernetes on GCP Install ...
	gcloudzone=$(gcloud config list | grep zone | awk '{print $3}')
	export KUBE_GCE_ZONE=$gcloudzone
	export KUBE_OS_DISTRIBUTION=coreos
	export KUBE_GCE_MASTER_PROJECT=coreos-cloud
	export KUBE_GCE_MASTER_IMAGE=$(gcloud compute images list | grep coreos | grep alpha | awk '{print $1}')
	export ENABLE_NODE_AUTOSCALER=false
	export AUTOSCALER_MAX_NODES=5
	export KUBE_ENABLE_CLUSTER_MONITORING=googleinfluxdb
	export KUBECTL_BIN=/opt/kubernetes/server/bin/kubectl

	pushd /tmp
	curl -sS https://get.k8s.io | bash
	popd 