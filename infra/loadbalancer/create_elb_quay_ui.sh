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

function create_new_elb {
	echo `date` - Creating New ELB
}

function modify_existing_elb {
	echo `date` - Found existing ELB
	aws elb modify-load-balancer-attributes \
	--load-balancer-name $AWS_CLUSTER_name-tectonic \
	--load-balancer-attributes
}

function modify_sg {
	sggroup=$(aws cloudformation describe-stack-resources --stack-name $AWS_CLUSTER_name | \
	jq '.StackResources[] | select (.LogicalResourceId == "SecurityGroupWorker")' | jq '.PhysicalResourceId' | tr -d '"')

	aws ec2 authorize-security-group-ingress \
	--group-id $sggroup \
	--cidr 0.0.0.0/0 \
	--protocol tcp --port 30080	

}

aws elb describe-load-balancers --load-balancer-name $AWS_CLUSTER_name-tectonic 2> /dev/null 1> /dev/null

if [ $? -eq 255 ] ; then
	create_new_elb
else
	modify_existing_elb
fi

modify_sg

echo `date` - Finished Executing $0