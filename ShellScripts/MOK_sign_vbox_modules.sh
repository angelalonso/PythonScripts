#!/bin/bash

for i in $(ls $(dirname $(modinfo -n vboxdrv))/vbox*.ko); do
  echo $i
  #sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der $i
  k=$(dirname $(modinfo -n vboxdrv))
  name=${i#"$k/"}
  name=${name%".ko"}
  sudo modprobe $name
done
