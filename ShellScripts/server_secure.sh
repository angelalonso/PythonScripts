#!/usr/bin/env bash

# STEPS:
#  update, upgrade, install tools
update_system() {
  sudo apt-get update && sudo apt-get upgrade
  sudo apt-get install vim git
}
#  create new user, give it admin access, add public key
add_user() {
  promptValue "Enter your user name"
  USER=$val
  useradd -m -s /bin/bash $USER 
  mkdir /home/$USER/.ssh 
  touch /home/$USER/.ssh/authorized_keys 
  chmod 600 /home/$USER/.ssh/authorized_keys 
  chown -R $USER:$USER /home/$USER 

  echo "Next you will be asked to add your public Key"
  echo 
  promptValue "Please look for it now and press <ENTER> when you are ready"
  vi /home/$USER/.ssh/authorized_keys 
  
  vigr
}
#  generic function to ask for user interaction
promptValue() {
 read -p "$1"": " val
}
#  change SSH Port
#  avoid SSH with password
#  avoid SSH as root

# IPTables
