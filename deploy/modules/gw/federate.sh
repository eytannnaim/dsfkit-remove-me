#!/bin/bash -x
set -e

dsf_hub_ip=$1
dsf_gw_ip=$2

while ! nc -z -v ${dsf_hub_ip} 8443 &>/dev/null; do
    echo "waiting for hub to go up"
    sleep 5
done
while ! nc -z -v ${dsf_gw_ip} 8443 &>/dev/null; do
    echo "waiting for gw to go up"
    sleep 5
done

# This sleep is a WA for federetion bug. This should be replaced with some grep on the sonar logs (intallation files)
sleep 300

ssh -o "StrictHostKeyChecking no" -i dsf_hub_ssh_key ec2-user@${dsf_hub_ip} -C 'sudo /opt/sonar-dsf/jsonar/apps/*/bin/federated warehouse '${dsf_hub_ip}' '${dsf_gw_ip}
ssh -o "StrictHostKeyChecking no" -i dsf_hub_ssh_key ec2-user@${dsf_gw_ip} -C 'sudo /opt/sonar-dsf/jsonar/apps/*/bin/federated remote'

