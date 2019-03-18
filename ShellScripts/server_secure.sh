#!/usr/bin/env bash

# STEPS:
#  update, upgrade, install tools
update_system() {
  sudo apt-get update && sudo apt-get upgrade
  sudo apt-get install vim 
}
#  create new user, give it admin access, add public key
add_user() {
  echo 
  echo "Before we start, make sure you have your SSH keypair ready at your local machine"
  echo '- you can generate one with: ssh-keygen -f filename -t rsa -b 4096 -C "your_email@example.com"'
  promptValue "Press Enter to continue"

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
  
  echo "Next you have to add $USER to the sudo group"
  promptValue "Press Enter to continue"
  vigr
}

#  change SSH Port
#  avoid SSH as root
#  avoid SSH with password
ssh_tweak() {
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
  promptValue "Enter your desired SSH PORT"
  SSHPORT=$val
  sudo sed -i 's/#Port 22/Port '$SSHPORT'/g' /etc/ssh/sshd_config
  # https://www.cyberciti.biz/faq/how-to-disable-ssh-password-login-on-linux/
  sudo sed -i 's/#PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
  sudo sed -i 's/#ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
  sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  sudo sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
  #sudo systemctl restart sshd
}
#  generic function to ask for user interaction
promptValue() {
 read -p "$1"": " val
}

# IPTables

update_system
add_user
ssh_tweak
