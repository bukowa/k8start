#!/bin/bash
set -eux
source k3sup.vars.sh

echo "Are you sure?"
read -r

function uninstall() {
  ssh k3s@${1} "/usr/local/bin/k3s-uninstall.sh || true && sudo rm -fr /mnt/longhorn/*" || true

}

uninstall $SERVER1
uninstall $SERVER2
uninstall $SERVER3
