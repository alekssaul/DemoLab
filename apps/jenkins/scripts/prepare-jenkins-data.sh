#!/bin/bash

echo `date` - Formatting Jenkins home drive ...
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-jenkins-home 2> /dev/stdout 1> /dev/null 
sudo mkdir /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
sudo mount -o discard,defaults /dev/disk/by-id/google-jenkins-home /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
# This is because; https://github.com/kubernetes/kubernetes/issues/2630
sudo chmod 777 /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 

if [ "$1" == "true" ]; then
	echo `date` - Restoring Jenkins data from gs://$2/$3	
	docker run -i --net=host -v /home/core/.config:/.config -v /tmp:/tmp  google/cloud-sdk gsutil cp gs://$2/$3 $4 2> /dev/stdout 1> /dev/null 
	echo `date` - Extracting data into jenkins home drive
	sudo tar -zxvf $4 -C /mnt/jenkins-home/ 2> /dev/stdout 1> /dev/null 
fi

sudo umount /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
sudo rmdir /mnt/jenkins-home 2> /dev/stdout 1> /dev/null 
