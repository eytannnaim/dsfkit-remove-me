#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "cd root" > /tmp/123.log
cd /root
yum update -y
echo "installing" > /tmp/123.log
/opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive --accept-eula --jsonar-uid-display-name "DSF-Hub" --jsonar-uid $(uuidgen) --not-remote-machine --product sonar-platform --newadmin-pass=${admin_password} --secadmin-pass=${secadmin_password} --sonarg-pass=${sonarg_pasword} --sonargd-pass=${sonargd_pasword}
echo "sourcing" > /tmp/123.log
source /etc/sysconfig/jsonar
echo "for each" > /tmp/123.log
for dir in "" "$${JSONAR_LOCALDIR}" "/tmpp/"; do
    mkdir -p $${dir}/home/sonarw/.ssh/
    /usr/local/bin/aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_private_ssh_key_name} --query SecretString --output text > $${dir}/home/sonarw/.ssh/id_rsa
    /usr/local/bin/aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_public_ssh_key_name} --query SecretString --output text > $${dir}/home/sonarw/.ssh/id_rsa.pub
    chown -R sonarw:sonar $${dir}/home/sonarw/.ssh/id_rsa*
    chmod 600 $${dir}/home/sonarw/.ssh/id_rsa*
done
