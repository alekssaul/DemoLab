#!/bin/bash
set -e

echo `date` - Executing $0 ...

COREUPDATE_NAMESPACE=${COREUPDATE_NAMESPACE:-coreupdate}

if [ $DemoLab_Infra="aws" ]; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig create namespace $COREUPDATE_NAMESPACE
kubeminions=$(kubectl --kubeconfig=$kubeconfig get nodes | grep -v SchedulingDisabled | grep -v NAME | awk '{print $1}')
for kubeminion in $kubeminions ; do kubeminionlabel=$kubeminion; done
kubectl --kubeconfig=$kubeconfig label node $kubeminionlabel coreupdate-postgres="true"

kubectl --kubeconfig=$kubeconfig --namespace=$COREUPDATE_NAMESPACE create -f $DemoLab_RootFolder/apps/coreupdate/manifests/coreupdate-db.yaml

echo `date` - Finished Executing $0 