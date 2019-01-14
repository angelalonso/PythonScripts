#!/usr/bin/env python3

import boto3

REGION = "eu-central-1"
VPC = "vpc-53e22d3a"
SEARCHED = "euvolo-"

ec2 = boto3.resource('ec2', region_name=REGION)
vpc = ec2.Vpc(VPC)

for i in vpc.instances.all():
    for tag in i.tags:
        if tag['Key'] == 'Name' and SEARCHED in tag['Value']:
          print(tag['Value'] + " " + i.id)
          #print(i.public_ip_address)
          print(i.private_ip_address)
