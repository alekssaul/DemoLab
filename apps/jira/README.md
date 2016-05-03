# DemoLab Atlassian jira install

Create JIRA namespace

```shell
kubectl create namespace jira
```

## Create PostgreSQL (non production)

Create Persistent Disk

```shell
gcloud compute disks create jira-pg-data-disk --size 50GB
```


```shell
kubectl --namespace=jira create -f postgres_persistence.yaml
kubectl --namespace=jira create -f postgres_claim.yaml
kubectl --namespace=jira create -f postgres_replicationcontroller.yaml
kubectl --namespace=jira create -f postgres_service.yaml
```

## Create JIRA App
```shell
kubectl create namespace jira

kubectl --namespace=jira create -f jira_replicationcontroller.yaml
kubectl --namespace=jira create -f jira_service.yaml
```

