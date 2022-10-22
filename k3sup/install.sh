#!/bin/bash
set -eux
source vars.sh

function install {
    k3sup install \
        --host=${1} \
        --ip=${2} \
        --user=k3s \
        --k3s-extra-args='
            --no-deploy=traefik 
            --kube-controller-manager-arg=--node-monitor-grace-period=16s 
            --kube-controller-manager-arg=--node-startup-grace-period=10s 
            --kube-controller-manager-arg=--node-monitor-period=4s 
            --kube-controller-manager-arg=--pod-eviction-timeout=20s  
            --kubelet-arg=--node-status-update-frequency=4s' \
        --print-command \
        --cluster
}

function join {
    k3sup join \
        --host=${1} \
        --ip=${2} \
        --user=k3s \
        --server-ip=${3} \
        --server \
        --server-user=k3s \
        --k3s-extra-args='--no-deploy=traefik --kube-controller-manager-arg=--node-monitor-grace-period=16s --kube-controller-manager-arg=--node-startup-grace-period=10s --kube-controller-manager-arg=--node-monitor-period=4s --kube-controller-manager-arg=--pod-eviction-timeout=20s --kubelet-arg=--node-status-update-frequency=4s' \
        --print-command
}

function ready {
      k3sup ready \
    --context default \
    --kubeconfig ./kubeconfig
}

install $HOST1 $SERVER1
ready
join $HOST2 $SERVER2 $SERVER1
ready
join $HOST3 $SERVER3 $SERVER1
ready

kubectl patch deployment coredns  --type='merge' -p '{"spec":{"replicas":3}}' --namespace=kube-system
kubectl patch deployment local-path-provisioner --type='merge' -p '{"spec":{"replicas":3}}' --namespace=kube-system
kubectl patch deployment metrics-server --type='merge' -p '{"spec":{"replicas":3}}' --namespace=kube-system


kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/deploy/prerequisite/longhorn-nfs-installation.yaml
#curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/scripts/environment_check.sh | bash
