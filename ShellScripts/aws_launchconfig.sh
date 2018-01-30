#!/usr/bin/env bash
LC_NAME="search-staging-elasticsearch-v003-20170124-165432-m4.2xlarge"
NEW_LC_NAME="search-staging-elasticsearch-v003-clean"

AMI="ami-xxxxxxxx"

AWS_PROF="xxxxxxx-staging"

get() {
AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names ${LC_NAME}
}
create() {
AWS_PROFILE="${AWS_PROF}" aws autoscaling create-launch-configuration \
  --launch-configuration-name ${NEW_LC_NAME} \
  --image-id ${AMI} \
  --key-name key-xxxxxx \
  --security-groups sg-xxxxxxxx \
  --user-data file://udata.sh \
  --iam-instance-profile xxxxxxxxxxx-role \
  --no-ebs-optimized \
  --instance-monitoring Enabled=true \
  --instance-type m4.xlarge \
  --block-device-mappings file://bdmap.json

#  --no-associate-public-ip-address \
}


#get
create

