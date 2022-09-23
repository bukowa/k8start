output "kube_config_path" {
  value = abspath(pathexpand("~/.kube/config"))
}

output "kube_config" {
  value = digitalocean_kubernetes_cluster.k8s-starter.kube_config[0].raw_config
  sensitive = true
}