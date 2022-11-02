#!/bin/bash
set -eux
source .env.sh

# shellcheck disable=SC2029
init() {
ssh "root@${1}" "curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC=\"
        server
        --cluster-init
        --tls-san=${1}
        --disable=traefik
        --node-external-ip=${1}
        --flannel-backend=wireguard-native
        --flannel-external-ip
        \" \
        INSTALL_K3S_CHANNEL='stable' sh -"
}

# shellcheck disable=SC2029
join_agent() {
ssh "root@${2}" "curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC=\"
        server
        --server=https://${1}:6443
        --token=${TOKEN}
        --tls-san=${2}
        --disable=traefik
        --node-external-ip=${2}
        --flannel-backend=wireguard-native
        --flannel-external-ip
        \" \
        INSTALL_K3S_CHANNEL='stable' sh -"
}

init "${SERVER1}"

until TOKEN="$(ssh "root@${SERVER1}" cat /var/lib/rancher/k3s/server/node-token)"
do
  sleep 3
done

join_agent "${SERVER1}" "${SERVER2}"
join_agent "${SERVER1}" "${SERVER3}"
join_agent "${SERVER1}" "${SERVER4}"

scp root@"${SERVER1}":/etc/rancher/k3s/k3s.yaml pwd && sed -i "s/127.0.0.1/${SERVER1}/g" k3s.yaml && export KUBECONFIG=$PWD/k3s.yaml
