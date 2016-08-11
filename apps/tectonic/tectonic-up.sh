#!/bin/bash
set -e 

${TECTONICNAMESPACE:-tectonic-system}
${TECTONIC_PULL_SECRET:-$HOME/Downloads/coreos-pull-secret.yaml}

kubectl create namespace $TECTONICNAMESPACE
kubectl --namespace=tectonic-system create -f "$TECTONIC_PULL_SECRET" 2> /dev/stdout 1> /dev/null
kubectl --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/replicationcontroller.yaml
kubectl --namespace=$TECTONICNAMESPACE create -f `dirname $0`/manifests/service.yaml