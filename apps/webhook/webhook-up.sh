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
if [[ $Github_BOTPassword ]]; then 
	cp `dirname $0`/manifests/replicationcontroller.yaml /tmp/webhook_rc.yaml
	sed -i 's@value: replacepassword@value: '$Github_BOTPassword'@g' /tmp/webhook_rc.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE create -f /tmp/webhook_rc.yaml
else
	kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
fi

kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE create -f `dirname $0`/manifests/service.yaml

WEBHOOK_SERVICEIP=$(kubectl --kubeconfig=$kubeconfig --namespace=$WEBHOOK_NAMESPACE get svc -o wide | grep webhook | awk '{print $3}')
until [ "$etcdhealth" == "true" ]; do 
	etcdhealth=$(kubectl --kubeconfig=$kubeconfig get cs | grep etcd | awk '{print $4}' | tr -d '"' | tr -d '}')
	sleep 60
done

sleep 120 

source $DemoLab_RootFolder/infra/dns/modify_dns.sh
modify_dns "$WEBHOOK_DNS" "$WEBHOOK_SERVICEIP"

echo `date` - Finished Executing $0 