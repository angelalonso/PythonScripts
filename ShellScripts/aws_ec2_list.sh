#/usr/bin/env bash

set pipefail -eo

ACCS=(account1 \
  account2 \
  )

REGS=(us-east-1 \
  us-east-2 \
  us-west-1 \
  us-west-2 \
  ap-south-1 \
  ap-northeast-1 \
  ap-northeast-2 \
  ap-southeast-1 \
  ap-southeast-2 \
  ca-central-1 \
  eu-central-1 \
  eu-west-1 \
  eu-west-2 \
  eu-west-3 \
  sa-east-1)

for acc in ${ACCS[@]} ;do
  echo "##############################" $acc
  for reg in ${REGS[@]} ;do
    echo "####---------------------#####" $acc " - " $reg
    AWS_PROFILE=$acc aws --region=$reg ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' | jq -r -s '.[][][][]' | sed 's/i-//g'
  done
done
