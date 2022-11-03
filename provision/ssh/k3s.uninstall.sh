#!/bin/bash
set -e
source .env.sh

echo "Are you sure?"; read -r
delete() {
  ssh "root@${1}" "rc-service k3s stop || true && /usr/local/bin/k3s-uninstall.sh || true && /usr/local/bin/k3s-agent-uninstall.sh || true" || true
}

delete "${SERVER1}"
delete "${SERVER2}"
delete "${SERVER3}"
delete "${SERVER4}"
