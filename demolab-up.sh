#!/bin/bash

# get default variables
echo `date` - Setting up configuration
./configure.sh


case $DemoLab_Infra in
	"gcp")
		echo `date` - Calling GCP Up ...
		./infra/gcp/gcp-up.sh ;;
	"aws")
		./infra/aws/aws-up.sh ;;	
	*) 
		echo `date` - Unsupported hook recieved ;;
esac


echo `date` - Starting Tectonic Up ...
./apps/tectonic/tectonic-up.sh

echo `date` - Starting Webhook Up ...
./apps/webhook/webhook-up.sh

echo `date` - Starting Jenkins Up ...
./apps/jenkins/jenkins-up.sh

