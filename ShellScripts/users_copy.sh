#!/usr/local/env bash

SERVER1=$1
SERVER2=$2

for user in $(ssh $SERVER1 "ls /home/")
do
  echo $user
#  ssh $SERVER2 "useradd -m -d /home/$user $user"
  scp $SERVER1:/home/$user/.ssh/authorized_keys ./authorized_keys_$user
done
