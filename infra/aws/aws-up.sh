#!/bin/bash
echo `date` - Started AWS UP Script ...
DemoLab_SETUP_TORUS=${DemoLab_SETUP_TORUS:-false}

echo `date` - Checking for requirements ...
	if [[ $(which kube-aws) ]]; then
		echo `date` - 	'	Found gcloud binary'
	else 
		echo `date` - ERROR: Could Not Found kube-aws binary
		exit 1 ;
	fi

pushd `dirname $0`/cluster

echo `date` - Rendering kube-aws assets
kube-aws render

if [ "$DemoLab_SETUP_TORUS" == "true" ]; then
	..\torus\torus-aws-setup.sh
fi

echo `date` - Executing kube-aws up
kube-aws up

popd