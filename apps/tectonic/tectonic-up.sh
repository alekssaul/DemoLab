#!/bin/bash
set -e 
TECTONICNAMESPACE=${TECTONICNAMESPACE:-tectonic-system}
TECTONIC_PULL_SECRET=${TECTONIC_PULL_SECRET:-$HOME/Downloads/coreos-pull-secret.yml}

echo `date` - Executing $0 ...

if [[ "$DemoLab_SETUP_TECTONIC_Enterprise" == "true" ]] ; then
	kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig
	if [ $DemoLab_Infra="aws" ]; then
		# Create ELB on AWS
		$DemoLab_RootFolder/infra/loadbalancer/create_elb_tectonic_ui.sh		
	fi	
	kubectl --kubeconfig=$kubeconfig create namespace $TECTONICNAMESPACE 2> /dev/stdout 1> /dev/null
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/tectonic-ca-cert-secret.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/tectonic-config.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/tectonic-console-tls-secret.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/tectonic-identity-tls-secret.yaml	
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/tectonic-identity-config-secret.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/tectonic-license.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f $DemoLab_RootFolder/secrets/coreos-pull-secret.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/tectonic-manager.yaml
else
	kubeconfig=$HOME/.kube/config 	
	kubectl --kubeconfig=$kubeconfig create namespace $TECTONICNAMESPACE 2> /dev/stdout 1> /dev/null
	kubectl --kubeconfig=$kubeconfig --namespace=tectonic-system create -f "$TECTONIC_PULL_SECRET" 2> /dev/stdout 1> /dev/null
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
	kubectl --kubeconfig=$kubeconfig --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/service.yaml
fi

echo `date` - Finished Executing $0 