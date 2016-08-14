#!/bin/bash
KUBERNETESFETCH=${KUBERNETESFETCH:-false}
KUBERNETESLOCATION=${KUBERNETESLOCATION:-$HOME/dev/workspace/kubernetes}
ENABLE_NODE_AUTOSCALER=${ENABLE_NODE_AUTOSCALER:-false}
AUTOSCALER_MAX_NODES=${AUTOSCALER_MAX_NODES:-5}


if [ "$KUBERNETESFETCH" == "false" ] && [ -e $KUBERNETESLOCATION ]; then
	echo `date` - Using Local Kubernetes Source $KUBERNETESLOCATION  ...
	$KUBERNETESLOCATION/cluster/kube-down.sh
else
	pushd /tmp
	./cluster/kube-down.sh
	popd 
fi