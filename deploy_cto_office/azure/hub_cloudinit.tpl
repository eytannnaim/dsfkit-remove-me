#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
sudo yum update -y
sudo yum install unzip -y
sudo yum install jq -y
sudo yum install lvm2 -y
sudo mkdir -p /opt/
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/azure-cli.repo
sudo yum install dnf -y
sudo dnf install azure-cli -y
sudo az login --identity
sudo az storage blob download-batch -d /tmp --pattern ${dsf_install_tarball} -s ${storage_container} --account-name ${storage_account} --auth-mode login




