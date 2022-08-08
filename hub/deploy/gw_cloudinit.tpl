#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
yum update -y
/opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive --accept-eula --jsonar-uid-display-name "DSF-Hub" --jsonar-uid $(uuidgen) --remote-machine --product sonar-platform --newadmin-pass=${admin_password} --secadmin-pass=${secadmin_password} --sonarg-pass=${sonarg_pasword} --sonargd-pass=${sonargd_pasword}
source /etc/sysconfig/jsonar
