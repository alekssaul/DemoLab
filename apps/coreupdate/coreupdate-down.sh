#!/bin/bash
set -e

echo `date` - Executing $0 ...

COREUPDATE_NAMESPACE=${COREUPDATE_NAMESPACE:-coreupdate}

if [ $DemoLab_Infra="aws" ]; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig delete namespace $COREUPDATE_NAMESPACE

echo `date` - Finished Executing $0 