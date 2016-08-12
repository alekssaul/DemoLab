#!/bin/bash

export DemoLab_Infra=gcp

# env | grep DemoLab_apps

echo `date` - Calling GCP Up ...
./infra/gcp/gcp-up.sh

echo `date` - Starting Tectonic Up ...

echo `date` - Starting Jenkins Up ...
./apps/jenkins/jenkins-up.sh

echo `date` - Starting Webhook Up ...
#./apps/webhook/webhook-up.sh



