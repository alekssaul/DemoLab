#!/bin/bash
set -e

echo `date` - Executing $0 ...

WEBHOOKNAMESPACE=${WEBHOOKNAMESPACE:-webhook}

kubectl create namespace $WEBHOOKNAMESPACE

kubectl --namespace=$WEBHOOKNAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
kubectl --namespace=$WEBHOOKNAMESPACE create -f `dirname $0`/manifests/service.yaml

echo `date` - Finished Executing $0 