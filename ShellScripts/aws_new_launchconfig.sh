#!/usr/bin/env bash
# Script to create a new Launch config for a Given Fleet,
# 


# Here we have the possibility to hardcode the default value of our parameters 
ASG=""
ASG_INSTANCE=""

DATE=$(date +%Y%m%d_%H%M%S)

get_awsprofile() {
  echo "Checking AWS_PROFILE..."
  AWS_PROF="$AWS_PROFILE"
  while [[ "$AWS_PROF" == "" ]]; do
    echo "No AWS PROFILE is defined"
    read -r -p "Please enter your AWS Profile:" AWS_PROF
  done
  export AWS_PROFILE=$AWS_PROF
  echo "- Done."
}

check_asg(){
  if [[ $(echo "${ASG}" | wc -w) -lt 1 ]]; then
    echo "ERROR: no ASGs found for that Fleet!"
    exit 2
  elif [[ $(echo "${ASG}" | wc -w) -gt 1 ]]; then
    echo "ERROR: SEVERAL ASGs found for that Fleet!"
    echo " Maybe there's a typo?"
    exit 2
  fi
  echo "- Done: ${ASG}"
}

get_asg() {
  echo "Getting ASG from Tag"
  ASG=$(aws autoscaling describe-auto-scaling-groups | jq -r --arg FLEET "$FLEET" '.[][] | select (.Tags[].Value==$FLEET)' | jq -r .AutoScalingGroupName)
  check_asg
}

get_data() {
  if [[ "${LCNAME_MSG}" == "" ]] ; then LCNAME_MSG="nopuppet"; fi
  echo "Getting data of current Launch Configuration"
  LC=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${ASG}" --query 'AutoScalingGroups[*].LaunchConfigurationName' | jq -r -s '.[][]')
  echo "  - LC: "$LC
  NEW_LC="${FLEET}"_"${LCNAME_MSG}"_"$DATE"
  echo "  - NEW_LC: $NEW_LC"
  AMI=$(aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].ImageId' | jq -r -s '.[][]')
  echo "  - AMI: $AMI"
  KEY=$(aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].KeyName' | jq -r -s '.[][]')
  echo "  - KEY: $KEY"
  SG=$(aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].SecurityGroups[0]' | jq -r -s '.[][]')
  echo "  - SG: $SG"
  IAM=$(aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].IamInstanceProfile' | jq -r -s '.[][]')
  echo "  - IAM: $IAM"
  INSTANCE_TYPE=$(aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].InstanceType' | jq -r -s '.[][]')
  echo "  - INSTANCE_TYPE: $INSTANCE_TYPE"
  
  aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].BlockDeviceMappings' | jq -r -s '.[][]' > bdmap.json
  aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].UserData' | jq -r -s '.[][]' | base64 --decode > udata.sh
  echo "----------------------"
  cat bdmap.json
  echo "----------------------"
  cat udata.sh
  echo "----------------------"
  echo "- Done."
}

get_instance_id() {
  if [[ "$ASG_INSTANCE" == "" ]]; then
    TMP_INSTANCE=$(aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?AutoScalingGroupName=='$ASG'].InstanceId" | jq -r -s '.[][0]')
    echo "ATTENTION!"
    echo "  NO INSTANCE provided to take the snapshot from"
    ANSWER=""
    while [[ "$ANSWER" == "" ]]; do 
      echo "-> Do you want to use the default one, $TMP_INSTANCE ?"
      echo "  Otherwise indicate a new instance ID"
      read -r -p "Please choose [y|instance_id]:" ANSWER
    done
    case $ANSWER in
      y|Y)
        ASG_INSTANCE=$TMP_INSTANCE
        ;;
      *)
        ASG_INSTANCE=$ANSWER
        ;;
    esac
  fi
}

newsnapshot() {
  get_instance_id
  echo "Creating a new AMI using $ASG_INSTANCE instance"
  NEW_AMI=$(aws ec2 create-image --no-reboot --description="scripted-image" --name="scripted-$ASG-$DATE" --instance-id $ASG_INSTANCE | jq -r -s '.[][]')
  echo "New AMI's id is $NEW_AMI"
  READY=""
  while [[ "$READY" != "available" ]]; do 
    echo "AMI Status is "$READY", waiting some seconds until it's available..."
    sleep 10
    READY=$(aws ec2 describe-images --image-ids=$NEW_AMI  --query "Images[*].State" | jq -r -s '.[][]')
  done

}

create() {
  ## NOTE: you can change user-data and Device Mapping by changing the related input files here
  aws autoscaling create-launch-configuration \
  --launch-configuration-name ${NEW_LC} \
  --associate-public-ip-address \
  --image-id ${NEW_AMI} \
  --key-name ${KEY} \
  --security-groups ${SG} \
  --iam-instance-profile $IAM \
  --instance-type $INSTANCE_TYPE \
  --no-ebs-optimized \
  --instance-monitoring Enabled=true \
  --user-data file://udata.sh \
  --block-device-mappings file://bdmap.json

#  --no-associate-public-ip-address \
  echo "LAUNCH CONFIG READY:"
  echo "      - "$NEW_LC
  use_lc
}

use_lc() {
  echo "-> Do you want to modify the AutoScalingGroup $ASG to use it?"
  ANSWER=""
  while [[ "$ANSWER" == "" ]]; do 
    read -r -p "Please choose [y|n]:" ANSWER
    case $ANSWER in
      y|Y)
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG --launch-configuration-name $NEW_LC
        echo "Switched $ASG to use $NEW_LC"
        echo 
        echo "Please have a look at your AWS console to check it's working fine"
        ;;
      n|N)
        echo "$ASG has NOT been modified"
        echo
        echo "Please update ASG "$ASG " manually if you want to use $NEW_LC"
        ;;
      *)
        ANSWER=""
        ;;
    esac
  done

}

show_help() {
  echo "USAGE:"
  echo "$0 <fleet name> <message> <instance-id>"
  echo "        - Creates a Launch Configuration"
  echo "   , where fleet name is front, vendorbackend, backend... (Fleet Tag on AWS)"
  echo "   , message is a name you can add to the LaunchConfig Name. Default is nopuppet"
  echo "   , instance-id is optional"
  echo "$0 -h   - shows this help"
  echo 
  exit 0
}

if [[ "$1" != "" ]]; then
  if [[ "$1" == "-h" ]]; then
    show_help
  else
    FLEET=$1
  fi
else
    show_help
fi
if [[ "$2" != "" ]]; then
  LCNAME_MSG=$2
fi
if [[ "$3" != "" ]]; then
  ASG_INSTANCE=$3
fi

get_awsprofile
get_asg
get_data
newsnapshot
create


