#!/bin/bash
set -e
echo `date` - Executing $0 ...

AWS_CLUSTER_name=${AWS_CLUSTER_name:-aleksdemo}
AWS_CLUSTER_AZ=${AWS_CLUSTER_AZ:-us-west-1c}
AWS_CLUSTER_region=${AWS_CLUSTER_region:-us-west-1}
export AWS_DEFAULT_REGION=$AWS_CLUSTER_region

sggroup=$(aws cloudformation describe-stack-resources --stack-name $AWS_CLUSTER_name | \
	jq '.StackResources[] | select (.LogicalResourceId == "SecurityGroupWorker")' | jq '.PhysicalResourceId' | tr -d '"')

aws elb delete-load-balancer \
	--load-balancer-name $AWS_CLUSTER_name-tectonic

aws ec2 revoke-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 32000

aws ec2 revoke-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 32001

echo `date` - Finished Executing $0