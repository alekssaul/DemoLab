#!/bin/bash
# Syntaxh :modify_dns URL replacement
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