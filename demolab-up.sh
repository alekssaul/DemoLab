#!/bin/bash

export DemoLab_Infra=gcp

# env | grep DemoLab_apps

echo `date` - Calling GCP Up ...
./infra/gcp/gcp-up.sh

echo `date` - Starting Tectonic ...

echo `date` - Starting Jenkins ...
./apps/jenkins/jenkins-up.sh

echo `date` - Starting Webhook ...
#./apps/webhook/webhook-up.sh



