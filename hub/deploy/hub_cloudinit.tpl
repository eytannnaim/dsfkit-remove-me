#!/bin/bash -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /root
yum update -y

# Formatting and mounting the external ebs device

## Find device name ebs external device
DEVICES=$(lsblk --noheadings -o NAME | grep "^[a-zA-Z]")
for d in $DEVICES; do
    if [ $(lsblk --noheadings -o NAME| grep $d | wc -l) -eq 1 ]; then
        DEVICE=$d;
        break;
    fi;
done

## Formatting the device
STATE_DIR=/opt/sonar-dsf/jsonar/state
mkdir -p $STATE_DIR/logs $STATE_DIR/local $STATE_DIR/data
mkfs -t xfs /dev/$DEVICE

## Mounting the device
echo "$(blkid /dev/$DEVICE | cut -d ' ' -f2 | awk '{print $1}') $STATE_DIR xfs defaults 0 0" | sudo tee -a /etc/fstab
mount -a

# Installing sonar sw as a hub
/opt/sonar-dsf/jsonar/apps/*/bin/sonarg-setup --no-interactive \
    --accept-eula \
    --jsonar-uid-display-name "DSF-Hub" \
    --jsonar-uid $(uuidgen) \
    --not-remote-machine \
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

for dir in "" "$${JSONAR_LOCALDIR}"; do
    mkdir -p $${dir}/home/sonarw/.ssh/
    /usr/local/bin/aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_private_ssh_key_name} --query SecretString --output text > $${dir}/home/sonarw/.ssh/id_rsa
    /usr/local/bin/aws secretsmanager get-secret-value --secret-id ${dsf_hub_sonarw_public_ssh_key_name} --query SecretString --output text > $${dir}/home/sonarw/.ssh/id_rsa.pub
    chown -R sonarw:sonar $${dir}/home/sonarw/.ssh
    chmod 600 $${dir}/home/sonarw/.ssh/id_rsa*
done
