#!/bin/bash
set -e

echo `date` - Executing $0 ...

WEBHOOK_NAMESPACE=${WEBHOOK_NAMESPACE:-webhook}

if [ $DemoLab_Infra="aws" ]; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE delete svc webhook
kubectl --kubeconfig=$kubeconfig delete namespace $WEBHOOK_NAMESPACE

