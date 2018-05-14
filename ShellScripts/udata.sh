#!/bin/bash
echo "#### Running initialisation script from S3"
wget -N https://s3-eu-west-1.amazonaws.com/userdata-legacy-europe/default-puppetless.sh -O /tmp/default-puppetless.sh
bash -x /tmp/default-puppetless.sh
