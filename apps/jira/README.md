# DemoLab Atlassian jira install

Create JIRA namespace

```shell
kubectl create namespace jira
```

## Create PostgreSQL (non production)

Create Persistent Disk

``` gcloud compute disks create jira-pg-data-disk --size 50GB ```

Deploy manifests

```shell
kubectl --namespace=jira create -f pxc-cluster-service.yaml 
kubectl --namespace=jira create -f pxc-node1.yaml 
kubectl --namespace=jira create -f pxc-node2.yaml 
kubectl --namespace=jira create -f pxc-node3.yaml 
```

## Create JIRA App
```shell
kubectl --namespace=jira create -f jira_replicationcontroller.yaml
kubectl --namespace=jira create -f jira_service.yaml
```