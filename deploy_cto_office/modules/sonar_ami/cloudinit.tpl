#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
yum update -y
yum install unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
aws/install
rm -rf aws awscliv2.zip

DIR=/opt/sonar-dsf
mkdir -p $DIR
# Download installation file
aws s3 cp  s3://${s3_bucket}/${dsf_install_tarball_path} .

useradd sonarg
useradd sonarw
groupadd sonar
usermod -g sonar sonarw
        
# Installation
tar -xf ${dsf_install_tarball_path} -gz -C $DIR
rm ${dsf_install_tarball_path}
chown -R sonarw:sonar $DIR
