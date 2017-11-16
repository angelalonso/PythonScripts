#/usr/bin/bash
#
# This script gets the password from keepass and mounts the Encfs folder
#      using that password

# Paths
## somehow this is not loaded from the config. No time for that now
HOME="/home/aaf"
FLD_SCRIPTS="$HOME/Software/laptop"
FLD_ENC_ORIG="$HOME/Dropbox/data/.encrypted"
FLD_ENC_DEST="$HOME/Private"


### Functions

# Mount the encfs folder
mount_encfs(){
  expect <<- DONE
     spawn encfs $FLD_ENC_ORIG $FLD_ENC_DEST
     expect "EncFS Password:"
     send    "$PASS_ENCFS\n"
     expect eof
DONE

}

### Main run

# Get the password from Keepass
GETPASS="$FLD_SCRIPTS/kp.sh"
. $GETPASS

# Call the mount function
mount_encfs

# Wait for the user to know what happened 
#   (this is meant to run in a terminal that will close afterwards)
echo "Press a key to continue"
read -n 1
