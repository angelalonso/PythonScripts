#/usr/bin/env bash

countries=(ci dz gh ke ma ng rw sn tz ug tn)

stg() {
# STAGING
AWSACCOUNT="xxxx-st"
SOURCE_FLDR="live-yyy-staging.xxxxyyy.io"
DEST_FLDR="xxxx-xxxx-yyy-stag"
PATH_FLDR="yyy/xxxxxxxx/staging"


for cc in ${countries[@]}; do
  echo "##### SYNCING $cc"
  AWS_PROFILE="$AWSACCOUNT" \
    aws s3 sync s3://$SOURCE_FLDR/${PATH_FLDR}/$cc  s3://$DEST_FLDR/${PATH_FLDR}/$cc
done
}

prod(){
# PRODUCTION
AWSACCOUNT="xxxx"
SOURCE_FLDR="live-yyy-production.xxxxyyy.io"
DEST_FLDR="xxxx-xxxx-yyy-prod"
PATH_FLDR="yyy/xxxxxxxx/production"


for cc in ${countries[@]}; do
  echo "##### SYNCING $cc"
  AWS_PROFILE="$AWSACCOUNT" \
    aws s3 sync s3://$SOURCE_FLDR/${PATH_FLDR}/$cc  s3://$DEST_FLDR/${PATH_FLDR}/$cc
done
}


# RUN!
stg
prod
