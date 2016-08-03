# DemoLab Hosted on GCP

## Requirements

- Google Cloud Platform Account
- gcloud utility need to exist in the system
- create a Project in Google Compute Engine
- ~2 GB free space as we need to pull down latest K8s release

## Getting Started

`infra_gcp_up.sh` script uses Google's way of setting up Kubernetes cluster with environmental variables provided to facilitate installation of CoreOS and sizing decisions based on my preferances

### Start Cluster

```
infra_gcp_up.sh
```

### Kill Cluster

Not ready yet