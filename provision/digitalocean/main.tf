
module "cluster" {
  source = "cluster"
  save_kube_config = true
  kube_config_path = "~/.kube/configs/k8start"
}

module "argocd" {
  source = "../modules/argocd/helm"
}

provider "helm" {
  kubernetes {
    config_path = module.cluster.kube_config_path
  }
}

output "argo_password" {
  value = module.argocd.argo_password
  sensitive = true
}
