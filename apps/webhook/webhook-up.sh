#!/bin/bash
set -e
WEBHOOKNAMESPACE=webhook
kubectl create namespace $WEBHOOKNAMESPACE

kubectl --namespace=$WEBHOOKNAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
kubectl --namespace=$WEBHOOKNAMESPACE create -f `dirname $0`/manifests/service.yaml