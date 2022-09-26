module "cluster" {
  source = "./cluster/digitalocean"
  save_kube_config = true
}

module "argocd" {
  source = "./argocd/helm"
  kube_config = module.cluster.kube_config
}

output "argo_password" {
  value = module.argocd.argo_password
  sensitive = true
}
