
output "argopass" {
  value = base64decode(data.kubernetes_secret.argopass.binary_data.password)
  sensitive = true
}