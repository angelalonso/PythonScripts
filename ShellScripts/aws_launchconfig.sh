#!/usr/bin/env bash
#TODO:
# cleanly pass AWS_PROFILE
# accept "cleanup" and find out what to clean


# Here we have the possibility to hardcode the default value of our parameters 
AWS_PROF=""
ASG=""
ASG_INSTANCE=""

DATE=$(date +%Y%m%d_%H%M%S)

get_asg() {
  if [[ "$ASG" == "" ]]; then
    echo "ATTENTION!"
    echo "  NO AUTOSCALING GROUP provided to create the Launch Configuration for"
    while [[ "$ASG" == "" ]]; do 
      read -r -p "Please enter AUTOSCALING GROUP:" ASG
    done
  fi
  EXISTS=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG | jq -r -s '.[][] | length') 
  if [[ $EXISTS -ne 1 ]]; then
    echo "ERROR!"
    echo "  The ASG provided does not exist: "$ASG
    echo "Exiting..."
    exit 2
  fi
}

get_data() {
  get_asg
  echo "Getting data of current Launch Configuration"
  LC=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG --query 'AutoScalingGroups[*].LaunchConfigurationName' | jq -r -s '.[][]')
  NEW_LC=$LC"_nopuppet_"$DATE
  AMI=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].ImageId' | jq -r -s '.[][]')
  KEY=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].KeyName' | jq -r -s '.[][]')
  SG=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].SecurityGroups[0]' | jq -r -s '.[][]')
  IAM=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].IamInstanceProfile' | jq -r -s '.[][]')
  INSTANCE_TYPE=$(AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].InstanceType' | jq -r -s '.[][]')
  #echo $LC
  #echo $AMI
  #echo $KEY
  #echo $SG
  #echo $IAM
  #echo $INSTANCE
  AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].BlockDeviceMappings' | jq -r -s '.[][]' > bdmap.json
  #AWS_PROFILE="${AWS_PROF}" aws autoscaling describe-launch-configurations --launch-configuration-names $LC --query 'LaunchConfigurations[*].UserData' | jq -r -s '.[][]' | base64 --decode > udata.sh
}

get_instance_id() {
  if [[ "$ASG_INSTANCE" == "" ]]; then
    TMP_INSTANCE=$(AWS_PROFILE=europe aws autoscaling describe-auto-scaling-instances --query "AutoScalingInstances[?AutoScalingGroupName=='$ASG'].InstanceId" | jq -r -s '.[][0]')
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
  NEW_AMI=$(AWS_PROFILE=europe aws ec2 create-image --no-reboot --description="scripted-image" --name="scripted-image-$ASG" --instance-id $ASG_INSTANCE | jq -r -s '.[][]')
  echo "New AMI's id is $NEW_AMI"
  READY=""
  while [[ "$READY" != "available" ]]; do 
    echo "AMI Status is "$READY", waiting some seconds until it's available..."
    sleep 10
    READY=$(AWS_PROFILE=europe aws ec2 describe-images --image-ids=$NEW_AMI  --query "Images[*].State" | jq -r -s '.[][]')
  done

}

create() {
AWS_PROFILE="${AWS_PROF}" aws autoscaling create-launch-configuration \
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
}

show_help() {
  echo "USAGE:"
  echo "$0 <aws_profile> <autoscaling group> <instance-id>"
  echo "        - Creates a Launch Configuration"
  echo "   , where instance-id is optional"
  echo "$0 -h   - shows this help"
  echo 
  exit 0
}

if [[ "$1" != "" ]]; then
  if [[ "$1" == "-h" ]]; then
    show_help
  else
    AWS_PROF=$1
  fi
else
    show_help
fi
if [[ "$2" != "" ]]; then
  ASG=$2
fi
if [[ "$3" != "" ]]; then
  ASG_INSTANCE=$2
fi
get_data
newsnapshot
create

