
output "kube_config" {
  value = digitalocean_kubernetes_cluster.starter.kube_config[0]
  sensitive = true
}

output "kube_config_path" {
  value = var.kube_config_path
}
