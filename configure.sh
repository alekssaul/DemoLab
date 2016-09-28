#!/bin/bash 

### Main Variables
export DemoLab_Infra=aws
export DemoLab_SETUP_JENKINS=false
export DemoLab_SETUP_TECTONIC=true
export DemoLab_SETUP_WEBHOOK=false
export DemoLab_Infra_TORUS=false
export DemoLab_RootFolder=$PWD
export DemoLab_GCP_DNSZone="alekssaul"
export DemoLab_TECTONIC_Enterprise=true

### Variables for GCP
if [ $DemoLab_Infra="gcp" ]; then
	export KUBERNETESFETCH=false
	export KUBERNETESLOCATION=$HOME/dev/workspace/kubernetes
	export ENABLE_NODE_AUTOSCALER=false
	export AUTOSCALER_MAX_NODES=5
fi 

### Variables for AWS
if [ $DemoLab_Infra="aws" ]; then
	export AWS_CLUSTER_DNS=tectonic.alekssaul.com
	export AWS_CLUSTER_name=aleksdemo
	export AWS_CLUSTER_region=us-west-1
	export AWS_CLUSTER_AZ=us-west-1c
	export AWS_CONFIG_controllerinstancetype=m3.medium
	export AWS_CONFIG_workerinstancetype=m3.medium
	export AWS_CONFIG_workerCount=2
	export AWS_DEFAULT_REGION=$AWS_CLUSTER_region
fi 

### Variables for Tectonic
if [ $DemoLab_SETUP_TECTONIC="true" ]; then	
	export TECTONICNAMESPACE=tectonic-system
	export TECTONIC_PULL_SECRET=$HOME/Downloads/coreos-pull-secret.yml
fi

### Variables for Webhook
if [ $DemoLab_SETUP_WEBHOOK="true" ]; then
	export WEBHOOKNAMESPACE=webhook
fi

### Variables for Jenkins
if [ $DemoLab_SETUP_JENKINS="true" ]; then
	export JENKINSNAMESPACE=jenkins
	export JENKINSRESTORE=true
	export JENKINSRESTORELOCATION=/tmp/jenkins-home.tar.gz
	export JENKINSDISK=jenkins-home
	export JENKINSPULLSECRET=$HOME/Downloads/dockercfg
	export KUBEMASTER=kubernetes-master
	export GCLOUDSTORAGE=asaul-jenkins
	export JENKINSBACKUPFILE=jenkins-home.tar.gz
	export JENKINSBACKUP=false
fi

