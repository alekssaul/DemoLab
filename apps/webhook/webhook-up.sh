#!/bin/bash
kubectl create namespace webhook
kubectl --namespace=webhook create -f manifests/replicationcontroller.yaml
kubectl --namespace=webhook create -f manifests/service.yaml