

Make sure to create persistent disk for Jenkins
```
gcloud compute disks create jenkins-home
```

Create Jenkins namespace, secrets, replication controllers and services.
```
kubectl create namespace jenkins
kubectl create --namespace=jenkins secret generic jenkins-pull-secret --from-file="$HOME/Downloads/dockercfg"
kubectl create --namespace=jenkins -f manifests
```

### workaround
Currently GCE Disk gets mounted with root only, either have to move jenkins container to run as root or wait for https://github.com/kubernetes/kubernetes/issues/2630 to be resolved, until then;
```
gcloud compute ssh core@$(kubectl --namespace=jenkins get pods --selector=role=leader -o 'jsonpath={.items[*].spec.nodeName}')
sudo chmod 777 /var/lib/kubelet/plugins/kubernetes.io/gce-pd/mounts/jenkins-data-disk
exit
```

Create Jenkins namespace, secrets, replication controllers and services.
```
kubectl create namespace jenkins
kubectl create --namespace=jenkins secret generic jenkins-pull-secret --from-file="$HOME/Downloads/dockercfg"
kubectl create --namespace=jenkins -f manifests
```

### workaround
Currently GCE Disk gets mounted with root only, either have to move jenkins container to run as root or wait for https://github.com/kubernetes/kubernetes/issues/2630 to be resolved, until then;
```
gcloud compute ssh core@$(kubectl --namespace=jenkins get pods --selector=role=leader -o 'jsonpath={.items[*].spec.nodeName}')
sudo chmod 777 /var/lib/kubelet/plugins/kubernetes.io/gce-pd/mounts/jenkins-data-disk
exit
```
