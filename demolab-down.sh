#!/bin/bash

# get default variables
./configure.sh

export DemoLab_Infra=gcp

# env | grep DemoLab_apps

echo `date` - Starting Tectonic Down ...
./apps/tectonic/tectonic-down.sh

echo `date` - Starting Jenkins Down ...
./apps/jenkins/jenkins-down.sh

echo `date` - Starting Webhook Down ...
./apps/webhook/webhook-down.sh

echo `date` - Calling GCP Down ...
./infra/gcp/gcp-down.sh