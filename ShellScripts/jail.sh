#!/usr/bin/env bash

CURRDIR=$(pwd)
DIR="${CURRDIR}/chroot"

mkdir -p ${DIR}
mkdir -p ${DIR}/etc
mkdir -p ${DIR}/bin

cd ${DIR}

umount ${DIR}/proc/
umount ${DIR}/sys/
umount ${DIR}/dev/

mount -t proc proc ${DIR}/proc/
mount --rbind /sys ${DIR}/sys/
mount --rbind /dev ${DIR}/dev/

#cp -r /usr ${DIR}/usr
#cp -r /lib ${DIR}/lib
#cp /bin/bash ${DIR}/bin/bash

cp /etc/resolv.conf ${DIR}/etc/resolv.conf

chroot ${DIR} /bin/bash
