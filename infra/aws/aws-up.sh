#!/bin/bash
echo `date` - Executing $0 ...
AWS_CLUSTER_DNS=${AWS_CLUSTER_DNS:-tectonic.alekssaul.com}
AWS_CLUSTER_name=${AWS_CLUSTER_name:-aleksdemo}
AWS_CLUSTER_region=${AWS_CLUSTER_region:-us-west-1}
AWS_CLUSTER_AZ=${AWS_CLUSTER_AZ:-us-west-1c}
DemoLab_GCP_DNSZone=${DemoLab_GCP_DNSZone:-alekssaul}

echo `date` - Checking for requirements ...
	if [[ $(which kube-aws) ]]; then
		echo `date` - Found kube-aws binary
	else 
		echo `date` - ERROR: Could Not Found kube-aws binary
		exit 1 ;
	fi

	if [[ $(which jq) ]]; then
		echo `date` - Found jq binary
	else 
		echo `date` - ERROR: Could Not Found jq binary
		exit 1 ;
	fi


if [ -z "AWS_CLUSTER_keypair" ] ; then echo `date` - ERROR: AWS_CLUSTER_keypair variable empty && exit 1; fi
if [ -z "AWS_CLUSTER_kms" ] ; then echo `date` - ERROR: AWS_CLUSTER_kms variable empty && exit 1; fi

mkdir `dirname $0`/cluster
pushd `dirname $0`/cluster 2> /dev/stdout 1> /dev/null 

echo `date` - Initializing files

kube-aws init --cluster-name=$AWS_CLUSTER_name \
--external-dns-name=$AWS_CLUSTER_DNS \
--region=$AWS_CLUSTER_region \
--availability-zone=$AWS_CLUSTER_AZ \
--key-name=$AWS_CLUSTER_keypair \
--kms-key-arn="$AWS_CLUSTER_kms"

case `uname -s` in
	Darwin)
	sed -i '' -e 's@# instanceCIDR: \"10.0.0.0/24\"@instanceCIDR: \"10.0.0.0/24\"@g' cluster.yaml
	sed -i '' -e 's@#workerInstanceType: m3.medium@workerInstanceType: '$AWS_CONFIG_workerinstancetype'@g' cluster.yaml
	sed -i '' -e 's@#controllerInstanceType: m3.medium@controllerInstanceType: '$AWS_CONFIG_controllerinstancetype'@g' cluster.yaml
	sed -i '' -e 's@#workerCount: 1@workerCount: '$AWS_CONFIG_workerCount'@g' cluster.yaml
	sed -i '' -e 's@#stackTags:@stackTags:@g' cluster.yaml
	sed -i '' -e 's@#  Name: \"Kubernetes\"@  Name: \"Kubernetes\"@g' cluster.yaml
	sed -i '' -e 's@#  Environment: \"Production\"@  Environment: \"'$AWS_CLUSTER_name'\"@g' cluster.yaml
	sed -i '' -e 's@# kubernetesVersion: v1.3.6_coreos.0@kubernetesVersion: v1.4.0_coreos.2@g' cluster.yaml
	;;

	*)
	sed -i 's@# instanceCIDR: \"10.0.0.0/24\"@instanceCIDR: \"10.0.0.0/24\"@g' cluster.yaml
	sed -i 's@#workerInstanceType: m3.medium@workerInstanceType: '$AWS_CONFIG_workerinstancetype'@g' cluster.yaml
	sed -i 's@#controllerInstanceType: m3.medium@controllerInstanceType: '$AWS_CONFIG_controllerinstancetype'@g' cluster.yaml
	sed -i 's@#workerCount: 1@workerCount: '$AWS_CONFIG_workerCount'@g' cluster.yaml
	sed -i 's@#stackTags:@stackTags:@g' cluster.yaml
	sed -i 's@#  Name: \"Kubernetes\"@  Name: \"Kubernetes\"@g' cluster.yaml
	sed -i 's@#  Environment: \"Production\"@  Environment: \"'$AWS_CLUSTER_name'\"@g' cluster.yaml
	sed -i 's@# kubernetesVersion: v1.3.6_coreos.0@kubernetesVersion: v1.4.0_coreos.2@g' cluster.yaml
	;;
esac

echo `date` - Rendering kube-aws assets
kube-aws render

# Make some changes to userdata
case `uname -s` in
	Darwin)
	sed -i '' -e 's@reboot-strategy: \"off\"@reboot-strategy: \"etcd-lock\"@g' userdata/cloud-config-worker
	sed -i '' -e 's@reboot-strategy: \"off\"@reboot-strategy: \"etcd-lock\"@g' userdata/cloud-config-controller
	;;

	*)
	sed -i 's@reboot-strategy: \"off\"@reboot-strategy: \"etcd-lock\"@g' userdata/cloud-config-worker
	sed -i 's@reboot-strategy: \"off\"@reboot-strategy: \"etcd-lock\"@g' userdata/cloud-config-controller
	;;
esac

cat userdata/cloud-config-worker | awk '/reboot-strategy: \"etcd-lock\"/{print;print "    group: 256600ee-81bb-43d3-bddb-b5fac96d69d7\n    server: http:\/\/coreupdate-app:8000\n  locksmith:\n    group: \"Tectonic Production\"\n    endpoint: \{\{ .ETCDEndpoints \}\}";next}1' > userdata/cloud-config-worker2
cat userdata/cloud-config-controller | awk '/reboot-strategy: \"etcd-lock\"/{print;print "    group: 256600ee-81bb-43d3-bddb-b5fac96d69d7\n    server: http:\/\/coreupdate-app:8000\n  locksmith:\n    group: \"Tectonic Production\"\n    endpoint: \"http:\/\/\$private_ipv4:2379\"";next}1' > userdata/cloud-config-controller2
mv userdata/cloud-config-worker2 userdata/cloud-config-worker
mv userdata/cloud-config-controller2 userdata/cloud-config-controller


if [ "$DemoLab_SETUP_TORUS" == "true" ]; then
	..\torus\torus-aws-setup.sh
fi

echo `date` - Executing kube-aws up
kube-aws up

kubeconfig=$DemoLab_RootFolder/infra/aws/cluster/kubeconfig

controllerIP=$(kube-aws status | grep Controller | awk '{print $3}')

# Setup DNS
dnsrecord=$(gcloud dns record-sets list --zone=$DemoLab_GCP_DNSZone --name "$AWS_CLUSTER_DNS." | grep $AWS_CLUSTER_DNS.)
if [[ -n $dnsrecord ]] ; then
	echo `date` - Adding DNS Record $controllerIP to $AWS_CLUSTER_DNS in GCP DNS
	dnsrecordtype=$(echo $dnsrecord | awk '{print $2}')
	dnsrecordttl=$(echo $dnsrecord | awk '{print $3}')
	dnsrecordvalue=$(echo $dnsrecord | awk '{print $4}')
	gcloud dns record-sets transaction start --zone=$DemoLab_GCP_DNSZone 
	gcloud dns record-sets transaction remove --zone=$DemoLab_GCP_DNSZone \
		--name "$AWS_CLUSTER_DNS." --ttl $dnsrecordttl --type $dnsrecordtype "$dnsrecordvalue"   
	gcloud dns record-sets transaction add --zone=$DemoLab_GCP_DNSZone \
		--name "$AWS_CLUSTER_DNS." --ttl $dnsrecordttl --type $dnsrecordtype "$controllerIP"   
	gcloud dns record-sets transaction execute --zone=$DemoLab_GCP_DNSZone
	rm -rf transaction.yaml
	echo `date` - Finished adding DNS Record $controllerIP to $AWS_CLUSTER_DNS in GCP DNS
fi

echo `date` - Waiting for kubectl connectivity to Kubernetes ... 
etcdhealth="false"
until [ "$etcdhealth" == "true" ]; do 
	etcdhealth=$(kubectl --kubeconfig=$kubeconfig get cs | grep etcd | awk '{print $4}' | tr -d '"' | tr -d '}')
	sleep 60
done
echo `date` - Done waiting for kubectl connectivity to Kubernetes ... 

popd
echo `date` - Finished Executing $0 