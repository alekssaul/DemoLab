#!/bin/bash 

# Demo Lab Infrastructure
export DemoLab_Infra=gcp

if [ $DemoLab_Infra="gcp" ]; then
	export KUBERNETESFETCH=false
	export KUBERNETESLOCATION=$HOME/dev/workspace/kubernetes
	export ENABLE_NODE_AUTOSCALER=false
	export AUTOSCALER_MAX_NODES=5
fi 

