#!/usr/bin/env bash
# Script to:
#   - Check if something on a Screen session is running (hence -lt 2) 
#   - Start it otherwise

CMD="mycommand"
FULLCMD="/home/sysadmin/mycommand parameters"
SCRN=$(which screen)
SCRNNAME="myscreen"


RUNNING=$(ps aux | grep $CMD | grep -v grep | wc -l)

if [ $RUNNING -lt 2 ]; then
  echo "$CMD stopped, starting..."
  ${SCRN} -X -S $SCRNNAME quit
  ${SCRN} -S $SCRNNAME -d -m bash -c "${FULLCMD}"
fi

