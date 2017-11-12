#!/usr/bin/env bash

CURRDIR=$(pwd)
DIR="${CURRDIR}/test"





dirs_prep() {
  echo "Preparing Directories"
  mkdir -p ${DIR}
  mkdir -p ${DIR}/etc
  mkdir -p ${DIR}/bin
  echo "All good"

}

debootstrap() {
#TODO: 
# Workaround to: 
#   E: Cannot install into target '/home/aaf/Software/Dev/Scripts/ShellScripts/debian' mounted with noexec or nodev
#     (maybe not using debootstrap at all)
# test debootstrap is installed
# choose distro (parameter?)
# https://wiki.ubuntu.com/DebootstrapChroot
# https://www.lucas-nussbaum.net/blog/?p=385
  echo "Installing system"

}

mounts_prep() {
  cd ${DIR}

  umount ${DIR}/proc/
  umount ${DIR}/sys/
  umount ${DIR}/dev/

  mount -t proc proc ${DIR}/proc/
  mount --rbind /sys ${DIR}/sys/
  mount --rbind /dev ${DIR}/dev/
}

files_prep() {
  rsync -avzh /usr ${DIR}
  rsync -avzh /lib ${DIR}
  rsync -avzh /bin ${DIR}

  cp /etc/resolv.conf ${DIR}/etc/resolv.conf
}

network() {
#TODO: 
# https://unix.stackexchange.com/questions/98808/how-to-assign-an-additional-ip-hostname-to-a-chrooted-environment
# add it's own network interface
  echo "Preparing its own IP"

}

dirs_prep
debootstrap
mounts_prep
files_prep
network

chroot ${DIR} /bin/bash
