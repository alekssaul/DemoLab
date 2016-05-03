# DemoLab Atlassian jira install

Create JIRA namespace

```shell
kubectl create namespace jira
```

## Create MySQL Galera cluster

Based on; https://github.com/kubernetes/kubernetes/tree/master/examples/mysql-galera

Create Persistent Disk

``` gcloud compute disks create jira-pg-data-disk --size 50GB ```

Deploy manifests

```shell
kubectl --namespace=jira create -f pxc-cluster-service.yaml 
kubectl --namespace=jira create -f pxc-node1.yaml 
kubectl --namespace=jira create -f pxc-node2.yaml 
kubectl --namespace=jira create -f pxc-node3.yaml 
```
Verify the cluster is healthy. (Note that the password is available in pxc-node yaml files)

```shell
MYSQLPOD=$(kubectl --namespace=jira get pods|grep pxc-node3|awk '{ print $1 }')
kubectl exec $MYSQLPOD -i -t -- mysql -u root -p -h pxc-cluster
```

## Create JIRA App
```shell
kubectl --namespace=jira create -f jira_replicationcontroller.yaml
kubectl --namespace=jira create -f jira_service.yaml
```