#!/bin/bash

sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-jenkins-home
sudo mkdir /mnt/jenkins-home
sudo mount -o discard,defaults /dev/disk/by-id/google-jenkins-home /mnt/jenkins-home
# This is because; https://github.com/kubernetes/kubernetes/issues/2630
sudo chmod 777 /mnt/jenkins-home
sudo umount /mnt/jenkins-home