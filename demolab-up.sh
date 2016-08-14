#!/bin/bash

# get default variables
./configure.sh

export DemoLab_Infra=gcp

# env | grep DemoLab_apps

echo `date` - Calling GCP Up ...
./infra/gcp/gcp-up.sh

echo `date` - Starting Tectonic Up ...
./apps/tectonic/tectonic-up.sh

echo `date` - Starting Webhook Up ...
./apps/webhook/webhook-up.sh

echo `date` - Starting Jenkins Up ...
#./apps/jenkins/jenkins-up.sh