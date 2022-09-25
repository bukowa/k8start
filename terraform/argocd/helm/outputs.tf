# outputs.tf

# argocd admin password
output "argo_password" {
  value = random_password.argo_password.result
  sensitive = true
}
