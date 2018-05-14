#/usr/bin/env bash

countries=(ci dz gh ke ma ng rw sn tz ug tn)

stg() {
# STAGING
AWSACCOUNT="jumia-st"
SOURCE_FLDR="live-cms-staging.foodcms.io"
#DEST_FLDR="jumia-food-cms-stag"
DEST_FLDR="cms-assets-staging.food.jumia.com"
PATH_FLDR="cms/foodpanda/staging"


for cc in ${countries[@]}; do
  echo "##### SYNCING $cc"
  AWS_PROFILE="$AWSACCOUNT" \
    aws s3 sync s3://$SOURCE_FLDR/${PATH_FLDR}/$cc  s3://$DEST_FLDR/staging/$cc
done
}

prod(){
# PRODUCTION
AWSACCOUNT="africa"
SOURCE_FLDR="live-cms-production.foodcms.io"
#DEST_FLDR="jumia-food-cms-prod"
DEST_FLDR="cms-assets.food.jumia.com"
PATH_FLDR="cms/foodpanda/production"


for cc in ${countries[@]}; do
  echo "##### SYNCING $cc"
  AWS_PROFILE="$AWSACCOUNT" \
    aws s3 sync s3://$SOURCE_FLDR/${PATH_FLDR}/$cc  s3://$DEST_FLDR/production/$cc
done
}


# RUN!
stg
prod
