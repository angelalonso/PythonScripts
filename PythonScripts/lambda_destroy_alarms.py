from __future__ import print_function
import json
import boto3
import logging

# AWS Account and Region Definition for Reboot Actions
akid = '<ID>'
region = '<REGION>'
name_tag = '<accountname>'

# Create AWS clients
ec2session = boto3.client('ec2')
cw = boto3.client('cloudwatch')

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

# Retrives instance id from cloudwatch event
def get_instance_id(event):
    try:
        return event['detail']['EC2InstanceId']
    except KeyError as err:
        LOGGER.error(err)
        return False


def lambda_handler(event, context):

    session = boto3.session.Session()
    ec2session = session.client('ec2')
    instanceid = get_instance_id(event)

    alarm_list = cw.describe_alarms(
        AlarmNamePrefix="%s %s" % (name_tag, instanceid),
    )

    for alarm in alarm_list['MetricAlarms']:
        response = cw.delete_alarms(
            AlarmNames=[
                alarm['AlarmName'],
        ]
    )
