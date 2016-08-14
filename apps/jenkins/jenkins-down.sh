#!/bin/bash
set -e 

JENKINSNAMESPACE=${JENKINSNAMESPACE:-jenkins}
JENKINSDISK=${JENKINSDISK:-jenkins-home}
JENKINSBACKUP=${JENKINSBACKUP:-jenkins-home.tar.gz}
KUBEMASTER=${KUBEMASTER:-kubernetes-master}
GCLOUDSTORAGE=${GCLOUDSTORAGE:-asaul-jenkins}
JENKINSBACKUP=${JENKINSBACKUP:-true}

echo `date` - Stopping Jenkins ...
kubectl --namespace=$JENKINSNAMESPACE scale rc jenkins-leader --replicas=0
kubectl --namespace=$JENKINSNAMESPACE scale rc jenkins-builder --replicas=0
kubectl --namespace=$JENKINSNAMESPACE delete rc jenkins-leader 
kubectl --namespace=$JENKINSNAMESPACE delete rc jenkins-builder
kubectl --namespace=$JENKINSNAMESPACE delete svc jenkins


if [ "$JENKINSBACKUP" == "true"  ]; then
	echo `date` - Backup up Jenkins ...
	gcloud compute instances attach-disk $KUBEMASTER --disk $JENKINSDISK --device-name jenkins-home 2> /dev/stdout 1> /dev/null 
	gcloud compute ssh core@$KUBEMASTER --command "sudo mkdir -p /mnt/jenkins-home"
	gcloud compute ssh core@$KUBEMASTER --command "sudo mount -o discard,defaults /dev/disk/by-id/google-$JENKINSDISK /mnt/jenkins-home"
	gcloud compute ssh core@$KUBEMASTER --command "sudo tar -zcvf /tmp/$JENKINSBACKUP /mnt/jenkins-home"
	echo `date` - Uploading Jenkins Backup to $GCLOUDSTORAGE 
	gcloud compute ssh core@KUBEMASTER --command "gsutil cp /tmp/$JENKINSBACKUP gs://$GCLOUDSTORAGE/$JENKINSBACKUP"				
fi

gcloud compute ssh core@$KUBEMASTER --command "sudo umount /mnt/jenkins-home"
gcloud compute instances detach-disk $KUBEMASTER --disk $JENKINSDISK  2> /dev/stdout 1> /dev/null 

echo `date` - Deleting $JENKINSDISK ...
gcloud compute disks delete $JENKINSDISK -q 2> /dev/stdout 1> /dev/null 