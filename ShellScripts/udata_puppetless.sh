#!/bin/bash
echo "#### Running initialisation script from S3"
wget -N https://s3-eu-west-1.amazonaws.com/userdata-legacy-europe/default_puppetless.sh -O /tmp/default.sh
wget -N https://s3-eu-west-1.amazonaws.com/userdata-legacy-europe/env-var.sh -O /tmp/env-var.sh
bash -x /tmp/default.sh
bash -x /tmp/env-var.sh
