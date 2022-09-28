
output "argo_password" {
  value = module.argocd.argo_password
  sensitive = true
}
