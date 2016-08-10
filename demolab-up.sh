#!/bin/bash

echo `date` - Calling GCP Up ...
./infra/gcp/gcp-up.sh

echo `date` - Starting Tectonic ...

echo `date` - Starting Webhook ...
kubectl create ./apps/webhook/webhook-up.sh

