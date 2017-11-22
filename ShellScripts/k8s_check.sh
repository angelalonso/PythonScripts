#!/usr/bin/env bash

# Script to check a list of applications on different K8s clusters
# It assumes you have a different config file for each cluster

KUBECFGFOLDR="$HOME/.kube"

# IMPORTANT: each array needs:
# - the same number of entries
# - in the same order
CLUSTERS=(QA3 STAGING PROD-ASIA PROD)
CONFIGS=(config.qa.kops config.staging.kops config.prod.asia.kops config.prod.kops)
EXTRAS=('--namespace qa3' '' '' '')
APPS=(lingo es-population swimlanes es-worker sapi )


for CLUSTER in $(seq 0 `expr ${#CLUSTERS[@]} - 1`); do
  echo "########### ${CLUSTERS[$CLUSTER]} ##############"
  config=${CONFIGS[${CLUSTER}]}
  extra=${EXTRAS[${CLUSTER}]}
  for app in ${APPS[@]}; do
    echo "### "$app
    echo kubectl --kubeconfig $KUBECFGFOLDR/$config $extra get po -lapp=$app
    kubectl --kubeconfig $KUBECFGFOLDR/$config $extra get po -lapp=$app
  done
  echo "Press a Key to Continue"
  read continue
done
