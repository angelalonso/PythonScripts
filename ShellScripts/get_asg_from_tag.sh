#!/usr/bin/env bash

PROF="europe"
FLEET="front"
#https://stackoverflow.com/questions/40027395/passing-bash-variable-to-jq-select
AWS_PROFILE=$PROF aws autoscaling describe-auto-scaling-groups | jq '.[][] | select (.Tags[].Value=="vendorbackend")' | jq .AutoScalingGroupName
