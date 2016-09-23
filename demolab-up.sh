#!/bin/bash

# get default variables
echo `date` - Setting up configuration
source ./configure.sh

echo `date` - Starting Kubernetes Cluster
case $DemoLab_Infra in
	"gcp")		
		./infra/gcp/gcp-up.sh ;;
	"aws")
		./infra/aws/aws-up.sh ;;	
	*) 
		echo `date` - Infrastructure type not set
		exit 1 ;;
esac

echo `date` - Deploying Applications
applications=$(env | grep DemoLab_SETUP | grep true)

for app in $Applications ; do 
	./app/$app/$app-up.sh; 
done

echo `date` - Done