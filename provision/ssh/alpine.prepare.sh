#!/bin/sh
# alpine
set -eu

apk update
apk add wireguard-tools
rc-update add cgroups default
rc-service cgroups start
swapoff -a

curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_ENABLE=true sh -
k3s check-config
