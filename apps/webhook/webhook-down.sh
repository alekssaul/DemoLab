#!/bin/bash
set -e
WEBHOOKNAMESPACE=${WEBHOOKNAMESPACE:-webhook}

kubectl --namespace=$WEBHOOKNAMESPACE delete svc webhook
kubectl delete namespace $WEBHOOKNAMESPACE 