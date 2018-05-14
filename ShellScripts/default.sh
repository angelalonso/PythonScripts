#!/bin/bash
set -eo pipefail

START_TIME=$(date +%s)

facter_facts() {
    mkdir -p /etc/facter/facts.d
    echo "intfd_role: ${INTFD_ROLE}" > /etc/facter/facts.d/intfd_role.yaml
    echo "intfd_region: ${INTFD_REGION}" > /etc/facter/facts.d/intfd_region.yaml
    echo "puppetmaster: puppet.private.vpc" > /etc/facter/facts.d/puppetmaster.yaml
}

puppet_config_client()
{
    mkdir -p /etc/puppet
    cat <<EOF > /etc/puppet/puppet.conf
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
confdir=/etc/puppet
pluginsync=true
ca_port=18140
environment=production
usecacheonfailure=false
certname=${FQDN}

[agent]
report=true
show_diff=true
server=puppet.private.vpc
configtimeout=15m
runinterval=20m
summarize=true
EOF
}

puppet_config_master()
{
    mkdir -p /etc/puppet
    cat <<EOF > /etc/puppet/puppet.conf
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
confdir=/etc/puppet
pluginsync=true
ca_server=ger-tools02.foodpanda.com
environment=production
usecacheonfailure=false
certname=${FQDN}

[agent]
report=true
show_diff=true
server=puppet.private.vpc
configtimeout=15m
runinterval=20m
summarize=true
EOF
}

tools_configure()
{
    mkdir /data
    apt-get update
    apt-get install --force-yes -y git rsync
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -A PREROUTING -p tcp --dport 18140 -j DNAT --to-destination 46.4.101.183:8140
    iptables -t nat -A POSTROUTING -j MASQUERADE
    cat << EOF > /root/.ssh/config
Host github.com
    StrictHostKeyChecking no
Host backup01.foodpanda.com
    StrictHostKeyChecking no
EOF

    # Private keys are in their own script

    mkdir /etc/ssl/intfd
    rm -rf /var/lib/puppet/ssl
    chmod -R 400 /root/.ssh
    git clone git@github.com:foodpanda/puppet.git /root/puppet
    git clone git@backup01.foodpanda.com:private-$INTFD_REGION /root/puppet/private
    cd /root/puppet
    git submodule init && git submodule update
    apt-get install -y puppet facter knockd puppetmaster puppetdb-terminus
    while ! nc -w5 -z ger-tools01.foodpanda.com 8140;
        do
            echo "Knocking on heavens door of ger-tools01.foodpanda.com"
            knock ger-tools01.foodpanda.com 81400 81400
        done
    puppet agent -tv --no-client --server ger-tools01.foodpanda.com --waitforcert 300
    cat << EOF > /etc/puppet/puppetdb.conf
[main]
server = ger-tools01.foodpanda.com
EOF
    cp /etc/puppet/private/ssl/foodpanda.com.key /etc/ssl/intfd/
    cp /etc/puppet/private/ssl/foodpanda.com.pem /etc/ssl/intfd/
    cp /etc/puppet/ec2_vpc.rb /usr/lib/ruby/vendor_ruby/facter/
    cp /root/puppet/private/passwords.yaml /etc/puppet/environments/production/data/
    service puppetmaster stop
    puppet agent --enable
    rsync -a --delete /root/puppet/ /etc/puppet
    service puppet start
}

function retry() {
  tries=0
  max_tries=10
  sleep_sec=4
  exit_code=256
  error=''

  until { error=$(${@} 2>&1 ); } {stdout}>&1; do
    exit_code=$?

    tries=$(( ${tries} + 1 ))
    if [[ ${tries} -gt ${max_tries} ]]; then
      exit ${exit_code}
    fi

    if [[ ${exit_code} == 255 ]] && (echo "${error}" | grep -q 'RequestLimitExceeded'); then
      if [[ ${tries} != 1 ]]; then
        sleep ${sleep_sec}
      fi
      sleep_sec=$((${sleep_sec} * 2))
      echo "${error}" >&2
      echo 'Being throttled. Retrying..' >&2
    else
      echo "${error}" >&2
      exit ${exit_code}
    fi
  done
  echo "${error}"
}

######################################################################
echo "#### Setting up repos and software"
mount -o remount,noatime /dev/xvda1
. /etc/os-release

if [[ ${VERSION_ID} == "14.04" ]]; then
  # We must use the puppetlabs repo because the Ubuntu 14.04 facter package is too old
  wget -N https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
  dpkg -i puppetlabs-release-pc1-trusty.deb
fi
if [[ ${VERSION_ID} == "16.04" ]]; then
  # This is a bugfix for INFRA-865
  systemctl stop apt-daily.service
  systemctl disable apt-daily.service
fi

apt-get update
apt-get install --force-yes -y facter python-pip python-setuptools puppet awscli jq
wget -N https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
easy_install aws-cfn-bootstrap-latest.tar.gz
######################################################################
echo "#### Setting important variables"
INSTANCE_IP=$(facter ipaddress)
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
AWS_EC2_AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone/)
AWS_REGION=${AWS_EC2_AZ::-1}
# ATTENTION: we already had problems with hitting the limit of API calls to AWS. Here we get 4 values in one call
#            IF at any point we can get Tags through a different system (meta-data, maybe?), please CHANGE THIS:
# For the instance as such
AWS_DETAILS=$(retry aws --output=json --region ${AWS_REGION} ec2 describe-tags --filters Name=resource-id,Values=${INSTANCE_ID})
AWS_CFN_STACK=$(echo $AWS_DETAILS | jq -r '.["Tags"][] | select(.Key=="aws:cloudformation:stack-name").Value')
INTFD_ROLE=$(echo $AWS_DETAILS | jq -r '.["Tags"][] | select(.Key=="Fleet").Value')
# For its tools host
AWS_TOOLS_DETAILS=$(retry aws --output=json --region ${AWS_REGION} ec2 describe-instances --filters Name=tag:Fleet,Values=tools Name=instance-state-name,Values=running --query Reservations[0].Instances[0])

if [[ ${AWS_CFN_STACK} == *"-"* ]]; then
  # Stack is nested so split stack name on '-' and use first element
  INTFD_REGION=(${AWS_CFN_STACK//-/ })
else
  # Stack is not nested
  INTFD_REGION=${AWS_CFN_STACK}
fi
HOSTNAME="${INTFD_REGION}-${INTFD_ROLE}-${INSTANCE_ID:2}"
FQDN="${HOSTNAME}.foodpanda.com"
######################################################################
echo "#### Setting /etc/hosts entries"
echo "${INSTANCE_IP}    ${FQDN}     ${HOSTNAME}" >> /etc/hosts
echo "${FQDN}" > /etc/hostname
hostname "${FQDN}"
######################################################################
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-cloud-init-users
facter_facts

if [[ ${INTFD_ROLE} == "tools" ]]; then
    puppet_config_master
    tools_configure
else
    puppet_config_client
fi

# current version of setuptools fails on installing pynacl, needs to be upgraded
pip install setuptools --upgrade
puppet agent --enable
puppet agent -t --waitforcert 60
service puppet restart

# Fixes false positive CloudWatch alarms for last Puppet run
touch /var/lib/puppet/state/state.yaml
sed -in 's/failure: .*/failure: 0/' /var/lib/puppet/state/last_run_summary.yaml
echo "#### AWS user-data execution complete"
END_TIME=$(date +%s)
TOTAL_TIME=$(expr $END_TIME-$START_TIME)
echo "User data run time. Total: $TOTAL_TIME"
exit 0

