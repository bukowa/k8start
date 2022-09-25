output "kube_config" {
  value = digitalocean_kubernetes_cluster.starter.kube_config[0]
  sensitive = true
}