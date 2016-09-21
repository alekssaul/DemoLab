#!/bin/bash 

### Main Variables
export DemoLab_Infra=gcp
export DemoLab_SETUP_JENKINS=true
export DemoLab_SETUP_TECTONIC=true
export DemoLab_SETUP_WEBHOOK=true
export DemoLab_SETUP_TORUS=false

### Variables based on requirements
if [ $DemoLab_Infra="gcp" ]; then
	export KUBERNETESFETCH=false
	export KUBERNETESLOCATION=$HOME/dev/workspace/kubernetes
	export ENABLE_NODE_AUTOSCALER=false
	export AUTOSCALER_MAX_NODES=5
fi 

