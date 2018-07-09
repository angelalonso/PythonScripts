#!/bin/bash
echo "#### Running initialisation script from S3"
echo "#### Running initialisation script from S3"
wget -N https://s3-ap-southeast-1.amazonaws.com/userdata-legacy-asia/default-puppetless.sh
bash -x default-puppetless.sh
echo "#### Running EIP association script from S3"
wget -N https://s3-ap-southeast-1.amazonaws.com/userdata-legacy-asia/associate-eip.sh
bash -x associate-eip.sh eipalloc-a35dbec6

