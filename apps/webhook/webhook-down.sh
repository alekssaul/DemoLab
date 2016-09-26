#!/bin/bash
set -e

echo `date` - Executing $0 ...

WEBHOOKNAMESPACE=${WEBHOOKNAMESPACE:-webhook}

if [[ "$DemoLab_SETUP_TECTONIC_Enterprise" == "true" ]] ; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOKNAMESPACE delete svc webhook
kubectl --kubeconfig=$kubeconfig delete namespace $WEBHOOKNAMESPACE

echo `date` - Finished Executing $0  