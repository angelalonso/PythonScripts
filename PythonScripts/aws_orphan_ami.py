# TODO: merge this and aws_old_amis.py
import boto
import boto3
import datetime
import dateutil
from dateutil import parser
from boto import ec2
import boto.ec2.autoscale

REGION = "ap-southeast-1"
OWNER = "xxxxxxxxxxxx"

autoscale_conn = ec2.autoscale.connect_to_region(REGION)

# Get all autoscale groups
ag = autoscale_conn.get_all_groups()

LC_list = []
for group in ag:
  if str(group.launch_config_name) == "None":
    pass
  else:
    LC_list.append(group.launch_config_name)
lc = autoscale_conn.get_all_launch_configurations()

AMI_list = []
for launch in lc:
    if launch.name not in LC_list:
        AMI_list.append(str(launch.image_id))

print AMI_list
