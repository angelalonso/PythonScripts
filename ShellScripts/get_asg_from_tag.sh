#!/usr/bin/env bash

FLEET="front"

while [[ "$AWS_PROF" == "" ]]; do
  echo "No AWS PROFILE is defined"
  read -r -p "Please enter your AWS Profile:" AWS_PROF
done
export AWS_PROFILE=$AWS_PROF
#https://stackoverflow.com/questions/40027395/passing-bash-variable-to-jq-select
#aws autoscaling describe-auto-scaling-groups | jq '.[][] | select (.Tags[].Value=="vendorbackend")' | jq .AutoScalingGroupName
aws autoscaling describe-auto-scaling-groups | jq -r --arg FLEET "$FLEET" '.[][] | select (.Tags[].Value==$FLEET)' | jq .AutoScalingGroupName
