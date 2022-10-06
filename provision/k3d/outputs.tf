
output "argo_password" {
  value = module.argocd.argo_password
  sensitive = true
}

output "kube_config_path" {
  value = local.kube_config_path
}
