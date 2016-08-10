#!/bin/bash
set -e 
TECTONICNAMESPACE=tectonic-system
kubectl create namespace $TECTONICNAMESPACE

kubectl --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
kubectl --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/service.yaml