#!/bin/bash
set -e 
TECTONICNAMESPACE=${TECTONICNAMESPACE:-tectonic-system}

echo `date` - Executing $0 ...

kubectl --namespace=$TECTONICNAMESPACE delete svc tectonic-console-public
kubectl delete namespace $TECTONICNAMESPACE

echo `date` - Finished Executing $0 