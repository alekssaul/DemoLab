#!/bin/bash

# env | grep DemoLab_apps

echo `date` - Calling GCP Up ...
./infra/gcp/gcp-up.sh

echo `date` - Starting Tectonic ...

echo `date` - Starting Webhook ...
./apps/webhook/webhook-up.sh

