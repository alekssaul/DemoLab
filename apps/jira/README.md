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
kubectl --namespace=jira exec $MYSQLPOD -i -t -- mysql -u root -p -h pxc-cluster
```

Verify That the cluster size is accurate

```shell
show status like 'wsrep_cluster_size';
````

should output

```
mysql> show status like 'wsrep_cluster_size';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| wsrep_cluster_size | 3     |
+--------------------+-------+
1 row in set (0.06 sec)
````

Create a new database for JIRA and assign rights to the user
```shell
CREATE DATABASE jira;
CREATE USER 'jira'@'%' IDENTIFIED BY 'jira';
GRANT ALL PRIVILEGES ON jira.* TO 'jira'@'%' WITH GRANT OPTION;
```

Create persistent disk

```shell
gcloud compute disks create --size=20GB jira-home
```

## Create JIRA App
```shell
kubectl --namespace=jira create -f jira_configmaps.yaml
kubectl --namespace=jira create -f jira_replicationcontroller.yaml
kubectl --namespace=jira create -f jira_service.yaml
```
Access JIRA application and walk through the wizard.

