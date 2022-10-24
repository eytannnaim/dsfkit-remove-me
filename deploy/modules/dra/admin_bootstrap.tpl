#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'
my_nameserver=$(ifconfig eth0 | grep "inet " | awk '{print $2}')
my_ip=$(ifconfig eth0 | grep "inet " | awk '{print $2}')
my_default_gw=$(ip route show | grep default | awk '{print $3}')
my_cidr=$(awk -F. '{                                     
    split($0, octets)
    for (i in octets) {
        mask += 8 - log(2**8 - octets[i])/log(2);
    }
    print mask
}' <<< $(ifconfig eth0 | grep "inet " | awk '{print $4}'))
sed '3 a export ITP_HOME=/opt/itp\nexport CATALINA_HOME=/opt/apache-tomcat' /opt/itp_global_conf/auto_deploy.sh > /opt/itp_global_conf/auto_deploy_tf.sh
chmod +x /opt/itp_global_conf/auto_deploy_tf.sh
sudo /opt/itp_global_conf/auto_deploy_tf.sh --hostname "$(hostname)" --ip-address "$my_ip" --dns-servers "$my_nameserver" --registration-password "${registration_password}" --cidr "$my_cidr" --default-gateway "$my_default_gw" --machine-type "Admin"
