#!/bin/bash

echo `date` - Setting up Jenkins ...
gcloud compute disks create jenkins-home

kubectl create namespace jenkins 2> /dev/stdout 1> /dev/null
kubectl create --namespace=jenkins secret generic jenkins-pull-secret --from-file="$HOME/Downloads/dockercfg" 2> /dev/stdout 1> /dev/null
kubectl create --namespace=jenkins -f manifests 2> /dev/stdout 1> /dev/null

