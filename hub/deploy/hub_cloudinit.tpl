#!/bin/bash
cd /root
yum update -y
/opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive --accept-eula --jsonar-uid-display-name "DSF-Hub" --jsonar-uid $(uuidgen) --not-remote-machine --product sonar-platform --newadmin-pass=${admin_password} --secadmin-pass=${secadmin_password} --sonarg-pass=${sonarg_pasword} --sonargd-pass=${sonargd_pasword}
aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_private_ssh_key_name} --query SecretString --output text > /home/sonarw/.ssh/id_rsa
aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_public_ssh_key_name} --query SecretString --output text > /home/sonarw/.ssh/id_rsa.pub
