#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
yum update -y
STATE_DIR=/opt/sonar-dsf/jsonar
/opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive \
    --accept-eula \
    --jsonar-uid-display-name "DSF-Hub" \
    --jsonar-uid $(uuidgen) \
    --remote-machine \
    --product sonar-platform \
    --newadmin-pass=${admin_password} \
    --secadmin-pass=${secadmin_password} \
    --sonarg-pass=${sonarg_pasword} \
    --sonargd-pass=${sonargd_pasword} \
    --jsonar-datadir=$STATE_DIR/data \
    --jsonar-localdir=$STATE_DIR/local \
    --jsonar-logdir=$STATE_DIR/logs

cat << EOF > /etc/profile.d/jsonar.sh
source /etc/sysconfig/jsonar
export JSONAR_BASEDIR
export JSONAR_DATADIR
export JSONAR_LOGDIR
export JSONAR_LOCALDIR
export JSONAR_VERSION
EOF

/usr/local/bin/aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_public_ssh_key_name} --query SecretString --output text >> /home/sonarw/.ssh/authorized_keys
chown sonarw:sonar /home/sonarw/.ssh/authorized_keys