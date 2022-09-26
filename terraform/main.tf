module "cluster" {
  source = "./cluster/digitalocean"
  save_kube_config = true
}

module "argocd" {
  source = "./argocd/helm"
}

output "argo_password" {
  value = module.argocd.argo_password
  sensitive = true
}

provider "helm" {
  kubernetes {
    config_path = module.cluster.kube_config_path
  }
}
