#!/bin/bash
set -eux

kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/deploy/prerequisite/longhorn-iscsi-installation.yaml
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/deploy/prerequisite/longhorn-nfs-installation.yaml
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.3.2/scripts/environment_check.sh | bash