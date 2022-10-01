TARGET_CLUSTER?=null_resource.k3d_cluster
TARGET_ARGOCD?=module.argocd
TARGET_WEBSTACK?=module.webstack

deploy: init apply-cluster apply-argocd apply-webstack
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

destroy-webstack:
	terraform destroy --auto-approve --target=${TARGET_WEBSTACK}
