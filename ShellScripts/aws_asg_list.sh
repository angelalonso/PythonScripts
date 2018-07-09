#!/usr/bin/env bash

ASGS=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?MinSize>`0`].[AutoScalingGroupName]' | jq '.[][]')


for asg in ${ASGS[@]}; do
  echo "###############################################"
  echo $asg
  INSTS=$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[?AutoScalingGroupName==`'$asg'`].[Instances][][].[InstanceId]' | jq '.[][]')
  for inst in ${INSTS[@]}; do
    echo $inst
  done
done
