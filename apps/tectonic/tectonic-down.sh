#!/bin/bash
set -e 
TECTONICNAMESPACE=${TECTONICNAMESPACE:-tectonic-system}
TECTONIC_PULL_SECRET=${TECTONIC_PULL_SECRET:-$HOME/Downloads/coreos-pull-secret.yml}

echo `date` - Executing $0 ...

if [[ "$DemoLab_SETUP_TECTONIC_Enterprise" == "true" ]] ; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
	if [ $DemoLab_Infra="aws" ]; then
		# Delete ELB on AWS
		$DemoLab_RootFolder/infra/loadbalancer/delete_elb_tectonic_ui.sh				
	fi
else
	kubeconfig=$HOME/.kube/config
fi

kubectl --kubeconfig=kubeconfig --namespace=$TECTONICNAMESPACE delete svc tectonic-console-public
kubectl --kubeconfig=kubeconfig delete namespace $TECTONICNAMESPACE

echo `date` - Finished Executing $0 