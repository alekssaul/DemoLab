#!/bin/bash
set -e 

JENKINSNAMESPACE=${JENKINSNAMESPACE:-jenkins}
JENKINSRESTORE=${JENKINSRESTORE:-true}
JENKINSRESTORELOCATION=${JENKINSRESTORELOCATION:-/tmp/jenkins-home.tar.gz}
JENKINSDISK=${JENKINSDISK:-jenkins-home}
JENKINSPULLSECRET=${JENKINSPULLSECRET:-$HOME/Downloads/dockercfg}
KUBEMASTER=${KUBEMASTER:-kubernetes-master}
GCLOUDSTORAGE=${GCLOUDSTORAGE:-asaul-jenkins}
JENKINSBACKUPFILE=${JENKINSBACKUPFILE:-jenkins-home.tar.gz}

echo `date` - Setting up Jenkins ...
if [ DemoLab_Infra=="gcp" ]; then
	echo `date` - Creating $JENKINSDISK on GCP ...
	gcloud compute disks create $JENKINSDISK --size 20GB 2> /dev/stdout 1> /dev/null 
	gcloud compute instances attach-disk $KUBEMASTER --disk $JENKINSDISK --device-name jenkins-home 2> /dev/stdout 1> /dev/null 
	gcloud compute copy-files `dirname $0`/scripts core@$KUBEMASTER:~/ 2> /dev/stdout 1> /dev/null 
	gcloud compute ssh core@$KUBEMASTER --command "~/scripts/prepare-jenkins-data.sh"
	if [ "$JENKINSRESTORE" == "true" ]; then		
		echo `date` - Restoring  Jenkins from $GCLOUDSTORAGE 
		gcloud compute ssh core@$KUBEMASTER --command "source ~/scripts/prepare-jenkins-data.sh $JENKINSRESTORE $GCLOUDSTORAGE $JENKINSBACKUPFILE $JENKINSRESTORELOCATION"
		#gcloud compute ssh core@kubernetes-master --command "source gsutil cp gs://$GCLOUDSTORAGE/$JENKINSBACKUPFILE $JENKINSRESTORELOCATION"
		#JENKINSKUBELOCATION=$(gcloud compute ssh core@kubernetes-master --command "sudo find / | grep jenkins-home.tar.gz")
		#tar -zxvf $JENKINSKUBELOCATION -C /mnt/jenkins-home/		
	else 
		gcloud compute ssh core@$KUBEMASTER --command "~/scripts/prepare-jenkins-data.sh"
	fi
	exit
	
	gcloud compute instances detach-disk $KUBEMASTER --disk jenkins-home 2> /dev/stdout 1> /dev/null
fi

echo `date` - Creating Jenkins assets ...
kubectl create namespace $JENKINSNAMESPACE 2> /dev/stdout 1> /dev/null
kubectl create --namespace=$JENKINSNAMESPACE secret generic jenkins-pull-secret --from-file=$JENKINSPULLSECRET 2> /dev/stdout 1> /dev/null
kubectl create --namespace=$JENKINSNAMESPACE -f `dirname $0`/manifests 2> /dev/stdout 1> /dev/null
