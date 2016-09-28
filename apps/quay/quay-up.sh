#!/bin/bash
set -e

echo `date` - Executing $0 ...
QUAY_NAMESPACE=${QUAY_NAMESPACE:-quay-enterprise}

if [ $DemoLab_Infra="aws" ] ; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=$kubeconfig  create -f $DemoLab_RootFolder/apps/quay/manifests/_quay-enterprise-namespace.yml
kubectl --kubeconfig=$kubeconfig --namespace=$QUAY_NAMESPACE create -f $TECTONIC_PULL_SECRET
kubectl --kubeconfig=$kubeconfig --namespace=$QUAY_NAMESPACE create -f  $DemoLab_RootFolder/apps/quay/manifests/quay-enterprise-config-secret.yml
kubectl --kubeconfig=$kubeconfig --namespace=$QUAY_NAMESPACE create -f  $DemoLab_RootFolder/apps/quay/manifests/quay-enterprise-redis.yml
kubectl --kubeconfig=$kubeconfig --namespace=$QUAY_NAMESPACE create -f  $DemoLab_RootFolder/apps/quay/manifests/quay-enterprise-service-nodeport.yml
kubectl --kubeconfig=$kubeconfig --namespace=$QUAY_NAMESPACE create -f  $DemoLab_RootFolder/apps/quay/manifests/quay-enterprise-app-rc.yml

echo `date` - Finished Executing $0 