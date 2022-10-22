#!/bin/bash
set -eux
source vars.sh

ssh k3s@${SERVER1} "/usr/local/bin/k3s-uninstall.sh" || true
ssh k3s@${SERVER2} "/usr/local/bin/k3s-uninstall.sh" || true
ssh k3s@${SERVER3} "/usr/local/bin/k3s-uninstall.sh" || true
