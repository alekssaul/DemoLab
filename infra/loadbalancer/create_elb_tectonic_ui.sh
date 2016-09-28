#!/bin/bash
set -e
echo `date` - Executing $0 ...

AWS_CLUSTER_name=${AWS_CLUSTER_name:-aleksdemo}
AWS_CLUSTER_AZ=${AWS_CLUSTER_AZ:-us-west-1c}
AWS_CLUSTER_region=${AWS_CLUSTER_region:-us-west-1}
export AWS_DEFAULT_REGION=$AWS_CLUSTER_region

echo `date` - Checking for requirements ...
	if [[ $(which aws) ]]; then
		echo `date` - Found AWS CLI binary
	else 
		echo `date` - ERROR: Could Not Found AWS CLI binary
		exit 1 ;
	fi

# get Information from Cloud formation
vpcid=$(aws cloudformation describe-stack-resources --stack-name $AWS_CLUSTER_name | \
	jq '.StackResources[] | select (.ResourceType == "AWS::EC2::VPC")' | jq '.PhysicalResourceId' | tr -d '"')

subnetid=$(aws cloudformation describe-stack-resources --stack-name $AWS_CLUSTER_name | \
	jq '.StackResources[] | select (.ResourceType == "AWS::EC2::Subnet")' | jq '.PhysicalResourceId' | tr -d '"')

sggroup=$(aws cloudformation describe-stack-resources --stack-name $AWS_CLUSTER_name | \
	jq '.StackResources[] | select (.LogicalResourceId == "SecurityGroupWorker")' | jq '.PhysicalResourceId' | tr -d '"')

workerASG=$(aws cloudformation describe-stack-resources --stack-name $AWS_CLUSTER_name | \
	jq '.StackResources[] | select (.ResourceType == "AWS::AutoScaling::AutoScalingGroup")' | jq '.PhysicalResourceId' | tr -d '"')

workerinstanceids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $workerASG | \
 	jq '.AutoScalingGroups[].Instances[].InstanceId' | tr -d '"')	

awselb=$(aws elb create-load-balancer \
	--load-balancer-name $AWS_CLUSTER_name-tectonic \
	--listeners Protocol=TCP,LoadBalancerPort=32000,InstanceProtocol=TCP,InstancePort=32000 Protocol=TCP,LoadBalancerPort=32001,InstanceProtocol=TCP,InstancePort=32001 \
	--subnets $subnetid \
	--security-groups $sggroup \
	--scheme Internet-facing)

tectonicelb=$(echo $awselb | jq '.DNSName' | tr -d '"')

echo `date` - Creating ELB and modifying settings ...

tectonicelbname=$(aws elb describe-load-balancers | jq '.LoadBalancerDescriptions[] | select (.DNSName == '\"$tectonicelb\"')' | \
	jq '.LoadBalancerName' | tr -d '"')

aws elb register-instances-with-load-balancer \
	--load-balancer-name $tectonicelbname \
	--instances $workerinstanceids 2> /dev/stdout 1> /dev/null 

aws elb configure-health-check \
	--load-balancer-name $tectonicelbname \
	--health-check Target=HTTPS:32001/health,Interval=30,Timeout=5,UnhealthyThreshold=2,HealthyThreshold=10 2> /dev/stdout 1> /dev/null 

aws ec2 authorize-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 32000 2> /dev/stdout 1> /dev/null 

aws ec2 authorize-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 32001 2> /dev/stdout 1> /dev/null 

aws autoscaling attach-load-balancers \
	--auto-scaling-group-name $workerASG \
	--load-balancer-names $tectonicelbname 2> /dev/stdout 1> /dev/null 

echo `date` - Finished creating ELB and modifying settings

function modify_dns () {
	dnsrecord=$(gcloud dns record-sets list --zone=$DemoLab_GCP_DNSZone --name "$1." | grep $1.)
	if [[ -n $dnsrecord ]] ; then
		echo `date` - Adding DNS Record $1 to $2 in GCP DNS
		dnsrecordtype=$(echo $dnsrecord | awk '{print $2}')
		dnsrecordttl=$(echo $dnsrecord | awk '{print $3}')
		dnsrecordvalue=$(echo $dnsrecord | awk '{print $4}')
		gcloud dns record-sets transaction start --zone=$DemoLab_GCP_DNSZone 2> /dev/stdout 1> /dev/null 
		gcloud dns record-sets transaction remove --zone=$DemoLab_GCP_DNSZone \
			--name "$1." --ttl $dnsrecordttl --type $dnsrecordtype "$dnsrecordvalue" 2> /dev/stdout 1> /dev/null 
		gcloud dns record-sets transaction add --zone=$DemoLab_GCP_DNSZone \
			--name "$1" --ttl $dnsrecordttl --type $dnsrecordtype "$2."   
		gcloud dns record-sets transaction execute --zone=$DemoLab_GCP_DNSZone 2> /dev/stdout 1> /dev/null 
		rm -rf transaction.yaml
		echo `date` - Finished adding DNS Record $1 to $2 in GCP DNS
	fi
}

# todo modify DNS 
if [ -a $DemoLab_RootFolder/secrets/tectonic-config.yaml ] ; then
	consoleurl=$( cat $DemoLab_RootFolder/secrets/tectonic-config.yaml | grep console-url | awk '{print $2}')
	identityurl=$( cat $DemoLab_RootFolder/secrets/tectonic-config.yaml | grep identity-issuer-url | awk '{print $2}')
	consolecname=$(echo $consoleurl | awk -F '//' '{print $2}'  | awk -F ':' '{print $1}')
	identitycname=$(echo $identityurl | awk -F '//' '{print $2}'  | awk -F ':' '{print $1}')
	modify_dns "$consolecname" "$tectonicelb"
	modify_dns "$identitycname" "$tectonicelb"
	echo `date` - INFO: Please make sure that $consoleurl and $identityurl CNAME points to $tectonicelb
	read -n1 -r -p "Press any key to continue..." key
fi 

echo `date` - Finished Executing $0