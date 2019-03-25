#!/usr/bin/env bash
# add parameter to skip worker and crons

KUBECONFIG_OLD="$HOME/.kube/config.prod.eu-v1.10.6"
KUBECONFIG_NEW="$HOME/.kube/config.prod.eu"

OLDKK="kubectl --kubeconfig ${KUBECONFIG_OLD}"
NEWKK="kubectl --kubeconfig ${KUBECONFIG_NEW}"

OLDFILE="old_deployed.txt"
NEWFILE="new_deployed.txt"

get_data() {
  echo "Getting data from the OLD CLUSTER..."
  ${OLDKK} get pods -L app,version,country | awk '{ print $6 " | " $7 " | " $8 }' | sort | uniq > ${OLDFILE}
  echo "Exit Code: $?"
  echo "Getting data from the NEW CLUSTER..."
  ${NEWKK} get pods -L app,version,country | awk '{ print $6 " | " $7 " | " $8 }' | sort | uniq > ${NEWFILE}
  echo "Exit Code: $?"
  echo "DONE!"

  echo "If you found ANY ERROR so far, please CTRL+C and check your credentials are correct."
  echo "otherwise, just press ENTER"
  read answer
}

trim_workers() {
  cp $OLDFILE $OLDFILE.all
  IFS=$'\n'
  rm -f $OLDFILE
  for i in $(cat $OLDFILE.all)
  do
    if [[ ! "${i}" =~ (worker|backend-cron|es-population|disco-pandora-loader) ]]; then
      echo "${i}" >> $OLDFILE
    fi
  done

  cp $NEWFILE $NEWFILE.all
  IFS=$'\n'
  rm -f $NEWFILE
  for i in $(cat $NEWFILE.all)
  do
    if [[ ! "${i}" =~ (worker|backend-cron|es-population|disco-pandora-loader) ]]; then
      echo "${i}" >> $NEWFILE
    fi
  done
}

compare() {
  while IFS= read -r var
  do
    SAME=$(grep "^$var$" $NEWFILE)
    if [[ "$SAME" == "" ]]; then
      APP=$(echo $var | awk -F  " | " '/1/ {print $1}')
      VERS=$(echo $var | awk -F  " | " '/1/ {print $3}')
      CC=$(echo $var | awk -F  " | " '/1/ {print $5}')
      NEWDEPLOYED=$(grep "$APP | .* | $CC" ${NEWFILE} )
      if [[ "$NEWDEPLOYED" == "" ]]; then
        echo "$var IS NOT DEPLOYED on the NEW cluster"
      else
        NEWVERS=$(echo $NEWDEPLOYED | awk -F  " | " '{print $3}')
        echo " - $APP - $CC should be on Version $VERS but has $NEWVERS on the new cluster"

      fi
    fi
  done < "$OLDFILE"
}

cleanup() {
  rm $OLDFILE.all 2>/dev/null
  rm $NEWFILE.all 2>/dev/null
}

show_help() {
  echo "SYNTAX:"
  echo -e "$0 \t\t\tCompare current versions of installed apps excluding workers"
  echo -e "$0 all \t\tCompare current versions of all installed apps"
  echo -e "$0 help \t\tShow this help"
}


if [ "$1" == "help" ]; then
  show_help
elif [ "$1" == "all" ]; then
  get_data
  compare
else
  get_data
  trim_workers
  compare
fi
#cleanup
