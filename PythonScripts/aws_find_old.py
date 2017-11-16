import boto
import datetime
import dateutil
from dateutil import parser
from boto import ec2
import boto.ec2.autoscale

REGION = "eu-central-1"
OWNER = "216648929716"
DAYS_OLD = 2
TIMELIMIT = datetime.datetime.now() - datetime.timedelta(days = DAYS_OLD)

#TODO:
# dry-run by default
# filter by name pattern


def get_snapshots():

  snapshot_conn = ec2.connect_to_region(REGION)
  snapshots = snapshot_conn.get_all_snapshots(
    filters = {
      'owner_id': OWNER,
    },
  )

  return snapshots


def get_AMIs():

  ami_conn = ec2.connect_to_region(REGION)
  amis = ami_conn.get_all_images(
    filters = {
      'image_type': 'machine',
      'owner_id': OWNER,
    },
  )

  return amis


def get_launchconfigs():

  launchconfig_conn = ec2.autoscale.connect_to_region(REGION)
  launchconfigs = launchconfig_conn.get_all_launch_configurations()
  token = launchconfigs.next_token
  while True:
    if token:
      r =  launchconfig_conn.get_all_launch_configurations(next_token=token)
      token = r.next_token
      launchconfigs.extend(r)
    else:
	  break

  return launchconfigs


def get_ASGs():

  asg_conn = ec2.autoscale.connect_to_region(REGION)
  asgs = asg_conn.get_all_groups()

  return asgs


def filter_objects(SnapShots, AMIs, LaunchConfigs, ASGs):
  # TODO: filter by tag

  # Get Launchconfigs that are NOT on the ASGs
  lcs_inuse = []
  for asg in ASGs:
    lcs_inuse.append(asg.launch_config_name)
  
  lc_amis_inuse = []
  lc_amis_notinuse = []
  lcs_notinuse = []
  for lc in LaunchConfigs:
    if lc.name not in lcs_inuse:
      lcs_notinuse.append(lc.name)
      lc_amis_notinuse.append(lc.image_id)
    else:
      lc_amis_inuse.append(lc.image_id)

  
  # Get AMIs that are NOT on the launchconfigs
  amis_inuse = []
  amis_notinuse = []
  for ami in AMIs:
    print ami
    if ami in lc_amis_inuse:
      amis_inuse.append(ami)
      amis_notinuse.append(ami)
  print "######"
  for i in lcs_inuse:
    print i
  print "######"
  for i in lc_amis_inuse:
    print i
  

  
def filter_down(SnapShots, AMIs, LaunchConfigs, ASGs):
  # TODO: filter by tag

  ami_inuse_ss = []
  for ami in AMIs:
    block = ami.block_device_mapping
    print str(block.items)

  ss_inuse = []
  for ss in SnapShots:
    ss_inuse.append(ss)

  print "############# Snapshots in use"
  for i in ss_inuse:
    print i.id
  print "############# Snapshots from AMIs in use"
  for i in ami_inuse_ss:
    print i
    
  


if __name__ == "__main__":
  SnapShots = get_snapshots()
  AMIs = get_AMIs()
  LaunchConfigs = get_launchconfigs()
  ASGs = get_ASGs()

  filter_down(SnapShots, AMIs, LaunchConfigs, ASGs)


