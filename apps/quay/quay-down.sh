#!/bin/bash
set -e

echo `date` - Executing $0 ...

QUAY_NAMESPACE=${QUAY_NAMESPACE:-quay-enterprise}

if [[ "$DemoLab_SETUP_TECTONIC_Enterprise" == "true" ]] ; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig --namespace=$QUAY_NAMESPACE delete svc quay-enterprise
kubectl --kubeconfig=$kubeconfig delete namespace $QUAY_NAMESPACE

echo `date` - Finished Executing $0  