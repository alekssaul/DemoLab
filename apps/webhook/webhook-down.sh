#!/bin/bash
set -e

echo `date` - Executing $0 ...

WEBHOOKNAMESPACE=${WEBHOOKNAMESPACE:-webhook}

kubectl --namespace=$WEBHOOKNAMESPACE delete svc webhook
kubectl delete namespace $WEBHOOKNAMESPACE

echo `date` - Finished Executing $0  