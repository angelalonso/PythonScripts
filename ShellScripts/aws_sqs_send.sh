#!/usr/bin/env bash
ACCOUNT=test
#QUEUE=https://sqs.eu-west-1.amazonaws.com/906315958670/INFRA-2172_TEST_sender
QUEUE=https://sqs.eu-west-1.amazonaws.com/476255873789/INFRA-2172-TEST

for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
  AWS_PROFILE=$ACCOUNT aws sqs send-message --queue-url $QUEUE --message-body "Information about the largest city in Any Region.$i" --delay-seconds 1 --message-attributes file://send-message.json
done
