import boto
import datetime
import dateutil
from dateutil import parser
from boto import ec2

REGION = "eu-west-1"
OWNER = "xxxxxxxxxxxx"
DAYS_OLD = 2

connection=ec2.connect_to_region(REGION)

ebsAllSnapshots=connection.get_all_snapshots(owner = OWNER)

timeLimit = datetime.datetime.now() - datetime.timedelta(days = DAYS_OLD)

SnapshotNr = 0
OldNr = 0
NewNr = 0
ErrNr = 0
for snapshot in ebsAllSnapshots:
  SnapshotNr += 1
  if parser.parse(snapshot.start_time).date() <= timeLimit.date():
    print " Snapshot %s  %s  %s"  %(snapshot.id,snapshot.start_time, snapshot.tags)
    OldNr += 1
    try:
#      print "deleting..."
      connection.delete_snapshot(snapshot.id)
    except boto.exception.EC2ResponseError:
      ErrNr += 1
  else:
    #print " Snapshot %s  %s  %s"  %(snapshot.id,snapshot.start_time, snapshot.tags)
    NewNr += 1

print "Total snapshots: " + str(SnapshotNr)
print "Tried to remove: " + str(OldNr)
print "Were not orphaned: " + str(ErrNr)
print "Were not older than " + str(DAYS_OLD) + " days: " + str(NewNr)
