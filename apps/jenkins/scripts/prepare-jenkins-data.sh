#!/bin/bash

echo `date` - Preparing Jenkins PD on an instance ...
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-jenkins-home 2> /dev/stdout 1> /dev/null 
sudo mkdir /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
sudo mount -o discard,defaults /dev/disk/by-id/google-jenkins-home /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
# This is because; https://github.com/kubernetes/kubernetes/issues/2630
sudo chmod 777 /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 

if [ "$1" == "true" ]; then
	echo `date` - Restoring Jenkins data	
	docker run -t -i --net=host -v /home/core/.config:/.config google/cloud-sdk -v /tmp:/tmp gsutil cp gs://$2/$3 $4
	JENKINSKUBELOCATION=$(sudo find / | grep jenkins-home.tar.gz)
	tar -zxvf $JENKINSKUBELOCATION -C /mnt/jenkins-home/
fi

sudo umount /mnt/jenkins-home
sudo rmdir /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
