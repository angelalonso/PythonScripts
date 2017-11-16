import boto
import datetime
import dateutil
from dateutil import parser
from boto import ec2

REGION = "eu-central-1"
OWNER = "216648929716"
DAYS_OLD = 2

connection=ec2.connect_to_region(REGION)

AllAGs = autoscale_conn.get_all_groups()


AllAmis=connection.get_all_images(
  filters={
    'image_type': 'machine',
    'owner_id': OWNER,
  },
)

timeLimit = datetime.datetime.now() - datetime.timedelta(days = DAYS_OLD)

AmiNr = 0
OldNr = 0
NewNr = 0
ErrNr = 0
for ami in AllAmis:
  print "%s %s " %(ami, ami.name)
#  print "%s %s %s" %(ami.id, ami.name, ami.tags)
  AmiNr += 1

print "Total AMIs: " + str(AmiNr)
print "Tried to remove: " + str(OldNr)
print "Were not orphaned: " + str(ErrNr)
print "Were not older than " + str(DAYS_OLD) + " days: " + str(NewNr)

#TODO:
# dry-run by default
# filter by name pattern
