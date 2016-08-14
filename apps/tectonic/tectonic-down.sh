#!/bin/bash
set -e 

TECTONICNAMESPACE=${TECTONICNAMESPACE:-tectonic-system}


echo `date` - Removing tectonic  ...
kubectl --namespace=$TECTONICNAMESPACE delete svc tectonic-console-public
kubectl delete namespace $TECTONICNAMESPACE