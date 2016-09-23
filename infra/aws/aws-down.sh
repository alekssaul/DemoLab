#!/bin/bash

echo `date` - Started AWS UP Script ...

echo `date` - Checking for requirements ...
	if [[ $(which kube-aws) ]]; then
		echo `date` - 	'	Found gcloud binary'
	else 
		echo `date` - ERROR: Could Not Found kube-aws binary
		exit 1 ;
	fi

pushd `dirname $0`/cluster

echo `date` - Executing kube-aws Destroy...
kube-aws destroy

echo `date` - Cleaning up the assets ...
rm -rf credentials stack-template.json userdata

