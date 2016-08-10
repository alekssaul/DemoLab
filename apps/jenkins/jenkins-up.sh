#!/bin/bash
set -e 

JENKINSNAMESPACE=jenkins
JENKINSRESTORE=YES
JENKINSRESTORELOCATION=
JENKINSDISK=jenkins-home
KUBEMASTER=kubernetes-master

echo `date` - Setting up Jenkins ...
if [ DemoLab_Infra=="gcp" ]; then
	echo `date` - Creating $JENKINSDISK on GCP ...
	gcloud compute disks create $JENKINSDISK --size 20GB 
	gcloud compute instances attach-disk $KUBEMASTER --disk $JENKINSDISK --device-name jenkins-home
	gcloud compute copy-files `dirname $0`/scripts core@kubernetes-master:~/
	gcloud compute ssh core@kubernetes-master --command "~/prepare-jenkins-data.sh"
	gcloud compute instances detach-disk kubernetes-master --disk jenkins-home
fi

if [ -z "$JENKINSRESTORE" ]; then
		echo `date` - Restoring Jenkins from $JENKINSRESTORELOCATION
fi

echo `date` - Creating Jenkins assets ...
kubectl create namespace $JENKINSNAMESPACE 2> /dev/stdout 1> /dev/null
kubectl create --namespace=$JENKINSNAMESPACE secret generic jenkins-pull-secret --from-file="$HOME/Downloads/dockercfg" 2> /dev/stdout 1> /dev/null
kubectl create --namespace=$JENKINSNAMESPACE -f `dirname $0`/manifests 2> /dev/stdout 1> /dev/null
