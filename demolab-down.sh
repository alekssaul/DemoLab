#!/bin/bash

# get default variables
echo `date` - Setting up configuration
./configure.sh


echo `date` - Starting Tectonic Down ...
./apps/tectonic/tectonic-down.sh

echo `date` - Starting Jenkins Down ...
./apps/jenkins/jenkins-down.sh

echo `date` - Starting Webhook Down ...
./apps/webhook/webhook-down.sh

case $DemoLab_Infra in
	"gcp")
		echo `date` - Calling GCP Down ...
		./infra/gcp/gcp-down.sh ;;
	"aws")
		./infra/aws/aws-down.sh ;;	
	*) 
		echo `date` - Unsupported hook recieved ;;
esac

