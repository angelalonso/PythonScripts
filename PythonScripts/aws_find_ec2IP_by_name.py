#!/usr/bin/env python3

import boto3

REGION = "eu-central-1"
VPC = "vpc-xxxxxx"
SEARCHED = "yyyyyyy"

ec2 = boto3.resource('ec2', region_name=REGION)
vpc = ec2.Vpc(VPC)

for i in vpc.instances.all():
    for tag in i.tags:
        if tag['Key'] == 'Name' and SEARCHED in tag['Value']:
          #print(tag['Value'])
          #print(i.public_ip_address)
          print(i.private_ip_address)
