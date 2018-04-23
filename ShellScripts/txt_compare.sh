#/usr/bin/env bash

set pipefail -eo

FILE1="./machines_ca.txt"
FILE2="./machines_running.txt"

FILTEROUT="#"

for word in $(cat $FILE2 | grep -v "$FILTEROUT"); do
  #echo $word
  grep $word $FILE1
done
