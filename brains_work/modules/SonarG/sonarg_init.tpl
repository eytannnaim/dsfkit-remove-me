#!/bin/bash
sudo su
hostname ${sonar_image_name}

###########################################################################################################
##### Temporarily storing certs in /tmp to copy into /home/sonarw/.ssh/ after setup process completes #####
###########################################################################################################
echo "${public_key}" > /tmp/id_rsa.pub
echo "${private_key}" > /tmp/id_rsa

sudo yum install epel-release -y
sudo yum install jq -y
sudo yum install lvm2 -y

sudo mkdir -p /opt/
sudo pvcreate -ff /dev/nvme1n1 -y
sudo vgcreate data /dev/nvme1n1 
sudo lvcreate -n vol0 -l 100%FREE data -y
sudo mkfs.xfs /dev/mapper/data-vol0
echo "$(blkid /dev/mapper/data-vol0 | cut -d ':' -f2 | awk '{print $1}') /opt xfs defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a

sudo groupadd sonar
sudo useradd -g sonar sonarw 
sudo useradd -g sonar sonargd        
sudo -u ec2-user mkdir /home/ec2-user/.aws
sudo -u ec2-user echo -e "[default] \naws_access_key_id=${aws_access_key_id} \naws_secret_access_key=${aws_secret_access_key}" > /home/ec2-user/.aws/credentials
sudo -u ec2-user echo -e "[default]\nregion=us-east-2\noutput=json" > /home/ec2-user/.aws/config
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo aws/install

sudo -u ec2-user aws s3 cp s3://octo-sonar-configs2/sonarg-4.9.1-1-3-gd279481e9.tar.gz /tmp/sonarg-4.9.1-1-3-gd279481e9.tar.gz
sudo -u ec2-user aws s3 cp s3://octo-sonar-configs2/${sonar_install_file} /tmp/${sonar_install_file}
        
sudo tar -xzvf /tmp/${sonar_install_file} -C /opt
sudo tar -xzvf /tmp/sonarg-4.9.1-1-3-gd279481e9.tar.gz -C /opt/jsonar/apps/${sonar_version}

sudo /opt/jsonar/apps/${sonar_version}/bin/python3 /opt/jsonar/apps/${sonar_version}/bin/sonarg-setup --no-interactive --accept-eula --remote-machine ${sonarw_ip} --newadmin-pass=${admin_password} --secadmin-pass=${secadmin_password}--sonarg-pass=${sonarg_pasword} --sonargd-pass=${sonargd_pasword} ${additional_parameters}


####################################################################################
##### Need to verify that the copy process below runs AFTER the commands       #####
##### above complete,otherwise the certs will be overwritten in setup process. #####
####################################################################################
sudo cp /tmp/id_rsa /home/sonarw/.ssh/id_rsa
sudo cp /tmp/id_rsa.pub /home/sonarw/.ssh/id_rsa.pub
sudo chown sonarw:sonar /home/sonarw/.ssh/id_rsa.pub
sudo chown sonarw:sonar /home/sonarw/.ssh/id_rsa
sudo chmod 600 /home/sonarw/.ssh/id_rsa
sudo chmod 644 /home/sonarw/.ssh/id_rsa.pub

sudo cp /tmp/id_rsa /home/sonarw/.ssh
sudo cp /tmp/id_rsa.pub /home/sonarw/.ssh
sudo chown sonarw:sonar /home/sonarw/.ssh/id_rsa.pub
sudo chown sonarw:sonar /home/sonarw/.ssh/id_rsa
sudo chmod 600 /home/sonarw/.ssh/id_rsa 
sudo chmod 644 /home/sonarw/.ssh/id_rsa.pub
sudo cat /home/sonarw/.ssh/id_rsa.pub >> /home/sonarw/.ssh/authorized_keys
sudo chown sonarw:sonar /home/sonarw/.ssh/authorized_keys

sudo cp /tmp/id_rsa /root/.ssh
sudo cp /tmp/id_rsa.pub /root/.ssh
sudo chmod 600 /root/.ssh/id_rsa 
sudo chmod 644 /root/.ssh/id_rsa.pub
sudo cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys