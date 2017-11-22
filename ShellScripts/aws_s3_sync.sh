#/usr/bin/env bash

countries=(ci dz gh ke ma ng rw sn tz ug tn)

# STAGING
AWSACCOUNT="xxxxxxxx"
SOURCE_FLDR="xxxxxxxxxxx"
DEST_FLDR="yyyyyyyyyyy"


for cc in ${countries[@]}; do
  echo "##### SYNCING $cc"
  AWS_PROFILE="$AWSACCOUNT" \
    aws s3 sync s3://$SOURCE_FLDR/path/$cc  s3://$DEST_FLDR/path/$cc
done

