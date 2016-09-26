#!/bin/bash
set -e
echo `date` - Executing $0 ...

AWS_CLUSTER_name=${AWS_CLUSTER_name:-aleksdemo}
AWS_CLUSTER_AZ=${AWS_CLUSTER_AZ:-us-west-1c}
AWS_CLUSTER_region=${AWS_CLUSTER_region:-us-west-1}
export AWS_DEFAULT_REGION=$AWS_CLUSTER_region

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
	--instances $workerinstanceids

aws elb configure-health-check \
	--load-balancer-name $tectonicelbname \
	--health-check Target=HTTPS:32001/health,Interval=30,Timeout=5,UnhealthyThreshold=2,HealthyThreshold=10

aws ec2 authorize-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 32000

aws ec2 authorize-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 32001

echo `date` - Finished creating ELB and modifying settings

# todo modify DNS 
if [ -a $DemoLab_RootFolder/secrets/tectonic-config.yaml ] ; then
	consoleurl=$( cat $DemoLab_RootFolder/secrets/tectonic-config.yaml | grep console-url | awk '{print $2}')
	identityurl=$( cat $DemoLab_RootFolder/secrets/tectonic-config.yaml | grep identity-issuer-url | awk '{print $2}')
	echo `date` - INFO: Please make sure that $consoleurl and $identityurl CNAME points to $tectonicelb
	read -n1 -r -p "Press any key to continue..." key
fi 

echo `date` - Finished Executing $0