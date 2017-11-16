#!/usr/bin/env bash
# Kubernetes
export KUBECONFIG_PROD_EU=$HOME/.kube/config.prod.eu
export KUBECONFIG_PROD_ASIA=$HOME/.kube/config.prod.asia
export KUBECONFIG_QA_EU=$HOME/.kube/config.qa.eu
export KUBECONFIG_QA_ASIA=$HOME/.kube/config.qa.asia
export KUBECONFIG_STAGING_EU=$HOME/.kube/config.staging.eu
export KUBECONFIG_STAGING_ASIA=$HOME/.kube/config.staging.asia



echo "########## EU PROD"
kubectl --kubeconfig $KUBECONFIG_PROD_EU get no | grep -v " Ready"
echo "########## EU ST"
kubectl --kubeconfig $KUBECONFIG_STAGING_EU get no | grep -v " Ready"
echo "########## EU QA"
kubectl --kubeconfig $KUBECONFIG_QA_EU get no | grep -v " Ready"


echo "########## ASIA PROD"
kubectl --kubeconfig $KUBECONFIG_PROD_ASIA get no  | grep -v " Ready"
echo "########## ASIA ST"
kubectl --kubeconfig $KUBECONFIG_STAGING_ASIA get no | grep -v " Ready"
echo "########## ASIA QA"
kubectl --kubeconfig $KUBECONFIG_QA_ASIA get no | grep -v " Ready"
