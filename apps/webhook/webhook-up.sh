#!/bin/bash
set -e

echo `date` - Executing $0 ...

WEBHOOK_NAMESPACE=${WEBHOOK_NAMESPACE:-webhook}
WEBHOOK_DNS=${WEBHOOK_DNS:-webhook.tectonic.alekssaul.com}
DemoLab_AWS_ELBName=${DemoLab_AWS_ELBName:-aleksdemo-tectonic}

if [ $DemoLab_Infra="aws" ]; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
else
	kubeconfig=$HOME/.kube/config
fi
kubectl --kubeconfig=$kubeconfig create namespace $WEBHOOK_NAMESPACE
kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml

#source $DemoLab_RootFolder/infra/dns/modify_dns.sh

if [ $DemoLab_Infra="aws" ]; then
	kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE create -f `dirname $0`/manifests/service_nodeport.yaml
else
	kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE create -f `dirname $0`/manifests/service.yaml
fi

#modify_dns "$WEBHOOK_DNS" "$WEBHOOK_SERVICEIP"

echo `date` - Finished Executing $0 