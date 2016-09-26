#!/bin/bash
set -e

echo `date` - Executing $0 ...

WEBHOOKNAMESPACE=${WEBHOOKNAMESPACE:-webhook}

kubectl create namespace $WEBHOOKNAMESPACE

if [[ "$DemoLab_SETUP_TECTONIC_Enterprise" == "true" ]] ; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOKNAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOKNAMESPACE create -f `dirname $0`/manifests/service.yaml

echo `date` - Finished Executing $0 