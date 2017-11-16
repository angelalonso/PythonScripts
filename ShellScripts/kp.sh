#!/bin/bash

keepass_db="/home/aaf/Documents/Security/Private_Copy/keefile.kdb"
keepass_key="/home/aaf/Documents/Security/kee/kee"
keepass_crypt_dir="Personal/Crypto"

echo "Please, enter the Keepass DB Password:"
read -s keepass_password
echo "Connecting to keepass Database..."

function get_creds {
  expect <<- DONE
     set timeout 5
     spawn kpcli
     match_max 100000000
     expect  "kpcli:/>"
     send    "open $keepass_db $keepass_key\n"
     expect  "Please provide the master password:"
     send    "$keepass_password\n"
     expect  ">"
     send    "cd $keepass_crypt_dir\n"
     expect  "Crypto>"
     send    "show -f encfs\n"
     expect  ">"
DONE

}

credentials=$(get_creds 2>/dev/null )
PASS_ENCFS=$(echo "$credentials" | grep 'Pass:' | sed -e 's/^.*: //')
#echo $PASS_ENCFS
