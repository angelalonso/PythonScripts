#!/bin/bash

# Script to get all 

API_USR=""
API_KEY=""

echo "-----------ENTERPRISE---------------"
curl -sSX GET "https://api.cloudflare.com/client/v4/zones/?per_page=1000" -H "X-Auth-Email: ${API_USR}" -H "X-Auth-Key: ${API_KEY}" -H "Content-Type: application/json" | jq -r '.[][] | select(.plan.name=="Enterprise Website") | .name' 


