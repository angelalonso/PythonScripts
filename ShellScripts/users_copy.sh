#!/usr/local/env bash



for server in $(cat /etc/hosts | grep whatever | awk '{print $2}' | sort | uniq); do
  echo $server
  for USER in user1 user2 ; do
    echo
    echo
    echo "##### USER $USER in $server #####"
    echo "Copying keys"
    sudo cp /home/$USER/.ssh/authorized_keys $HOME/keys_$USER && sudo chown afonseca. $HOME/keys_$USER
    ## ATTENTION: MODIFY THIS!
    scp $HOME/keys_$USER afonseca@$server:/home/afonseca/keys_$USER
    ssh $server "sudo useradd -m -s /bin/bash $USER; sudo mkdir /home/$USER/.ssh; sudo mv /home/afonseca/keys_$USER /home/$USER/.ssh/authorized_keys; sudo chmod 600 /home/$USER/.ssh/authorized_keys; sudo chown -R $USER. /home/$USER; sudo vigr"
    #ssh $server "sudo useradd -m -s /bin/bash $USER; sudo mkdir /home/$USER/.ssh; sudo mv /home/afonseca/keys_$USER /home/$USER/.ssh/authorized_keys; sudo chmod 600 /home/$USER/.ssh/authorized_keys; sudo chown -R $USER. /home/$USER; sudo usermod -a -G admin $USER"

    rm $HOME/keys_$USER
  done

done
