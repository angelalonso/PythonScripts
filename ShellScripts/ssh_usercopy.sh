#!/usr/bin/env bash

# Script to copy ssh config (keys included) between hosts
SERV1=$1
SERV2=$2

USRS=(afonseca)

echo "copying from $SERV1 to $SERV2"

for user in ${USRS[@]}; do
  echo $user
  ssh ubuntu@$SERV2 "sudo useradd -m -d /home/$user $user"
  ssh ubuntu@$SERV2 "sudo mkdir -p /home/$user/.ssh"
  ssh ubuntu@$SERV2 "sudo chsh -s /bin/bash $user"
  #TODO:
  # copy public keys
  # copy groups (id)
done

