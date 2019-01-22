#!/usr/bin/env bash
ACCOUNT=europe
QUEUE=https://sqs.eu-west-1.amazonaws.com/476255873789/INFRA-2172-TEST

AWS_PROFILE=$ACCOUNT aws sqs send-message --queue-url $QUEUE --message-body "Information about the largest city in Any Region." --delay-seconds 10 --message-attributes file://send-message.json
