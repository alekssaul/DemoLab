#!/bin/bash
set -e 

JENKINSNAMESPACE=jenkins
JENKINSRESTORE=YES
JENKINSRESTORELOCATION=
JENKINSDISK=jenkins-home
JENKINSBACKUP=jenkins-home.tar.gz
KUBEMASTER=kubernetes-master
GCLOUDSTORAGE=asaul-jenkins

echo `date` - Stopping up Jenkins ...
kubectl --namespace=$JENKINSNAMESPACE scale rc jenkins-leader --replicas=0
kubectl --namespace=$JENKINSNAMESPACE scale rc jenkins-builder --replicas=0

echo `date` - Backup up Jenkins ...
gcloud compute instances attach-disk $KUBEMASTER --disk $JENKINSDISK --device-name jenkins-home 2> /dev/stdout 1> /dev/null 
gcloud compute ssh core@$KUBEMASTER --command "sudo mkdir -p /mnt/jenkins-home"
gcloud compute ssh core@$KUBEMASTER --command "sudo mount -o discard,defaults /dev/disk/by-id/google-$JENKINSDISK /mnt/jenkins-home"
gcloud compute ssh core@$KUBEMASTER --command "sudo tar -zcvf /tmp/$JENKINSBACKUP /mnt/jenkins-home"
gcloud compute ssh core@$KUBEMASTER --command "sudo umount /mnt/jenkins-home"
gcloud compute instances detach-disk $KUBEMASTER --disk $JENKINSDISK  2> /dev/stdout 1> /dev/null 

echo `date` - Downloading Jenkins data ...
gcloud compute copy-files core@kubernetes-master:/tmp/$JENKINSBACKUP /tmp/$JENKINSBACKUP

echo `date` - Copying Jenkins data to GCE Storage ...
gsutil cp /tmp/$JENKINSBACKUP gs://$GCLOUDSTORAGE

echo `date` - Deleting $JENKINSDISK ...
gcloud compute disks delete $JENKINSDISK -q