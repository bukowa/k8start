TARGET_CLUSTER?=null_resource.k3d_cluster
TARGET_ARGOCD?=module.argocd
TARGET_WEBSTACK?=module.webstack
TARGET_PROM?=helm_release.prom_stack
TARGET_LOKI?=helm_release.loki
TARGET_PROMTAIL?=helm_release.promtail

deploy: init apply-cluster apply-argocd apply-webstack apply-prom apply-loki apply-promtail
.PHONY: init apply-cluster apply-argocd apply-webstack destroy-webstack

init:
	terraform init

apply-cluster:
	terraform apply --auto-approve --target=${TARGET_CLUSTER}

destroy-cluster:
	terraform destroy --auto-approve --target=${TARGET_CLUSTER}

apply-argocd:
	terraform apply --auto-approve --target=${TARGET_ARGOCD}

apply-webstack:
	terraform apply --auto-approve --target=${TARGET_WEBSTACK}

apply-prom:
	terraform apply --auto-approve --target=${TARGET_PROM}

apply-loki:
	terraform apply --auto-approve --target=${TARGET_LOKI}

apply-promtail:
	terraform apply --auto-approve --target=${TARGET_PROMTAIL}

destroy-webstack:
	terraform destroy --auto-approve --target=${TARGET_WEBSTACK}

destroy:
	terraform destroy
