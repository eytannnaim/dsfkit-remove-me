#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
yum update -y
STATE_DIR=/data_vol/sonar-dsf/jsonar
mkdir -p $STATE_DIR/logs $STATE_DIR/local $STATE_DIR/data

/opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive \
    --accept-eula \
    --jsonar-uid-display-name "${display-name}" \
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

mkdir -p /home/sonarw/.ssh
echo "${federation_public_key}" >> /home/sonarw/.ssh/authorized_keys
chown -R sonarw:sonar /home/sonarw