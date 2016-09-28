#!/bin/bash

# get default variables
echo `date` - Setting up configuration
source ./configure.sh
source secrets/secrets.sh

echo `date` - Removing Applications
applications=$(env | grep DemoLab_SETUP_ | grep true)

for app in $applications ; do 
	appname=$(echo $app | awk -F '[_=]' '{print $3}' |  tr '[:upper:]' '[:lower:]')
	./apps/$appname/$appname-down.sh; 
done

echo `date` - Destroying Kubernetes Cluster
case $DemoLab_Infra in
	"gcp")		
		./infra/gcp/gcp-down.sh ;;
	"aws")
		./infra/aws/aws-down.sh ;;	
	*) 
		echo `date` - Infrastructure type not set
		exit 1 ;;
esac

echo `date` - Done