#!/bin/bash
set -eux

export NAMESPACE="argocd"
export VERSION="5.6.3"
export PASSWORD="admin"
#export ARGOCD_VALUES="$(<application.argocd.values.yaml)"

helm repo add argo https://argoproj.github.io/argo-helm

function install {
  kubectl create namespace ${NAMESPACE}
  helm install --namespace ${NAMESPACE} argocd argo/argo-cd --version=${VERSION} \
    --set=configs.secret.argocdServerAdminPassword="$(htpasswd -nbBC 10 "" ${PASSWORD} | tr -d ':\n' | sed 's/$2y/$2a/')"
}

function self_manage {
  # https://github.com/mikefarah/yq/discussions/1164#discussioncomment-2559353
#  yq 'with(.. | select(. == "*${*-*}*"); . |= envsubst)' application.argocd.yaml | kubectl apply -f -
  kubectl apply -f application.argocd.yaml
}

function uninstall {
  helm uninstall --namespace ${NAMESPACE} argocd
  kubectl delete namespace ${NAMESPACE}
  kubectl get customresourcedefinitions.apiextensions.k8s.io -o=json | jq -r '.items[] | .metadata.name' | grep .argoproj.io | xargs kubectl delete crd
}

if [[ ${1:-install} == "rm" ]]; then
  uninstall
  exit 0
else
  install
  kubectl rollout status deployment --namespace=${NAMESPACE} argocd-server
  self_manage
fi

if [[ ${1:-install} == "pf" ]]; then
  kubectl port-forward service/argocd-server -n argocd 8080:443
fi
