#!/usr/bin/env bash

SSH_KEY="~/.ssh/key_id_rsa"
SSH_USER="bastionuser"
BASTION="00.000.00.000"

PORT_LOCAL="3307"
PORT_DB="3306"

countries=(ci dz gh ke ma ng rw sn tz ug tn)



#mysql -u ${DB_USER} -p -h 127.0.0.1 -P ${PORT_LOCAL}

stg_get(){
DB_SERVER="staging-database.live-private.vpc"
DB_USER="xxxx"
DB_PASS="xxxxxxxxxxxxxxxx"


ssh -N -L ${PORT_LOCAL}:${DB_SERVER}:${PORT_DB} -i ${SSH_KEY} ${SSH_USER}@${BASTION} &
PID=$!

sleep 4

for cc in ${countries[@]}; do
  mysqldump -uroot -h 127.0.0.1 -P ${PORT_LOCAL} -p"${DB_PASS}" staging_$cc > staging_$cc.sql
done

kill $PID
}

prod_get(){
DB_SERVER="production-database.live-private.vpc"
DB_USER="xxxx"
DB_PASS="xxxxxxxxxxxxxxxx"


ssh -N -L ${PORT_LOCAL}:${DB_SERVER}:${PORT_DB} -i ${SSH_KEY} ${SSH_USER}@${BASTION} &
PID=$!

sleep 4

for cc in ${countries[@]}; do
  mysqldump -uroot -h 127.0.0.1 -P ${PORT_LOCAL} -p"${DB_PASS}" production_$cc > production_$cc.sql
done

kill $PID
}


stg_put(){
for cc in ${countries[@]}; do
  #rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress staging_$cc.sql root@52.210.235.47:/root/mysql_dumps
  rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress staging_$cc.sql user@host.com:/home/user/mysql_dumps
done
}

prod_put(){
for cc in ${countries[@]}; do
  rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress production_$cc.sql user@host.com:/home/user/mysql_dumps
done
}

stg_get
prod_get
stg_put
prod_put
