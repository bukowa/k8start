#!/bin/bash
set -eux
source .env.sh

# shellcheck disable=SC2029
cluster_init() {
ssh "root@${1}" "curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC=\"
        server
        --cluster-init
        --tls-san=${1}
        --disable=traefik
        --node-external-ip=${1}
        --flannel-backend=wireguard-native
        --flannel-external-ip
        --kube-apiserver-arg=--default-not-ready-toleration-seconds=20
        --kube-apiserver-arg=--default-unreachable-toleration-seconds=30
        --kubelet-arg=--node-status-update-frequency=4s
        --kube-controller-manager-arg=--node-monitor-period=2s
        --kube-controller-manager-arg=--node-monitor-grace-period=20s
        --kube-controller-manager-arg=--pod-eviction-timeout=5s
        \" \
        INSTALL_K3S_CHANNEL='v1.25' sh -"
}

join_agent() {
ssh "root@${2}" "curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC=\"
        agent
        --server=https://${1}:6443
        --token=${TOKEN}
        --node-external-ip=${2}
        --kubelet-arg=--node-status-update-frequency=4s
        \" \
        INSTALL_K3S_CHANNEL='v1.25' sh -"
}

cluster_init "${SERVER1}"

until TOKEN="$(ssh "root@${SERVER1}" cat /var/lib/rancher/k3s/server/node-token)"
do
  sleep 3
done

join_agent "${SERVER1}" "${SERVER2}"
join_agent "${SERVER1}" "${SERVER3}"
join_agent "${SERVER1}" "${SERVER4}"

scp root@"${SERVER1}":/etc/rancher/k3s/k3s.yaml $(pwd) && sed -i "s/127.0.0.1/${SERVER1}/g" k3s.yaml && export KUBECONFIG=$PWD/k3s.yaml

kubectl rollout status deployment --namespace=kube-system coredns
kubectl patch deployment coredns  --type='merge' -p '{"spec":{"replicas":4}}' --namespace=kube-system

helm install --version=4.3.0 nginx ingress-nginx/ingress-nginx --values ingress-nginx.values.deploy.yaml
helm install --version=1.19.5 dns coredns/coredns --values coredns.values.deploy.yaml

# shellcheck disable=SC2029
#join_server() {
#ssh "root@${2}" "curl -sfL https://get.k3s.io | \
#  INSTALL_K3S_EXEC=\"
#        server
#        --server=https://${1}:6443
#        --token=${TOKEN}
#        --tls-san=${2}
#        --disable=traefik
#        --node-external-ip=${2}
#        --flannel-backend=wireguard-native
#        --flannel-external-ip
#        --kube-proxy-arg=proxy-mode=ipvs
#        --kube-apiserver-arg=--default-not-ready-toleration-seconds=20
#        --kube-apiserver-arg=--default-unreachable-toleration-seconds=30
#        --kubelet-arg=--node-status-update-frequency=4s
#        --kube-controller-manager-arg=--node-monitor-period=2s
#        --kube-controller-manager-arg=--node-monitor-grace-period=20s
#        --kube-controller-manager-arg=--pod-eviction-timeout=5s
#        \" \
#        INSTALL_K3S_CHANNEL='stable' sh -"
#}
