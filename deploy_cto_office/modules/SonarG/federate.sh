#!/bin/bash -x
set -e

hub_ip=$1
gw_ip=$2
dsf_version=$3

sudo su sonarw

while ! nc -z -v ${hub_ip} 8443 &>/dev/null; do
    echo "waiting for hub to go up"
    sleep 5
done
while ! nc -z -v ${gw_ip} 8443 &>/dev/null; do
    echo "waiting for gw to go up"
    sleep 5
done

# This sleep is a WA for federetion bug. This should be replaced with some grep on the sonar logs (intallation files)
sleep 120

ssh -o "StrictHostKeyChecking no" sonarw@${hub_ip} << HERE
while [ -f sync_file ]; do
    sleep 5;
done
touch sync_file
sudo /opt/jsonar/apps/${dsf_version}/bin/federated warehouse '${hub_ip}' '${gw_ip}'
rm sync_file
HERE

ssh -o "StrictHostKeyChecking no" sonarw@${hub_ip} -C 'sudo /opt/sonar-dsf/jsonar/apps/${dsf_version}/bin/federated remote'
