#!/usr/bin/env python

import boto.ec2
import sys

ec2 = {}
iam = ''
rds = ''
s3 = ''
sns = ''
sqs = ''

ec2['awscli'] = 'aws ec2 describe-instances --filters \
                "Name=instance-type,Values=m1.small"'
ec2['boto'] = boto.ec2.instanceinfo


def search(regexp, service):
    pass


def create(service):
    pass

if __name__ == '__main__':
    options = {'search': search,
               'Search': search,
               'SEARCH': search,
               's': search,
               'S': search,
               'create': create,
               }

    try:
        mode = sys.argv[1]
    except IndexError:
        mode = 'search'

    options[mode](sys.argv[2], sys.argv[3])
