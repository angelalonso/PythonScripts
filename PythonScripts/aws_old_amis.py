import boto
import datetime
import dateutil
from dateutil import parser
from boto import ec2

REGION = "ap-southeast-1"
OWNER = "xxxxxxxxxxxx"
DAYS_OLD = 2

connection=ec2.connect_to_region(REGION)

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
  print ami.id
  AmiNr += 1

print "Total AMIs: " + str(AmiNr)
print "Tried to remove: " + str(OldNr)
print "Were not orphaned: " + str(ErrNr)
print "Were not older than " + str(DAYS_OLD) + " days: " + str(NewNr)
