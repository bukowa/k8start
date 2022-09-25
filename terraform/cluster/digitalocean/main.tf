resource "digitalocean_kubernetes_cluster" "starter" {
  name    = "k8s-starter"
  region  = "fra1"
  version = data.digitalocean_kubernetes_versions.versions.latest_version
  auto_upgrade = true
  node_pool {
    name = "cheap-pool"
    size = "s-1vcpu-2gb"
    node_count = 2
  }
}

locals {
  kube_config_path = abspath(pathexpand(var.kube_config_path))
}

resource "local_sensitive_file" "kube_config" {
  count = var.save_kube_config ? 1 : 0
  filename = local.kube_config_path
  content = digitalocean_kubernetes_cluster.starter.kube_config[0].raw_config
}

data "digitalocean_kubernetes_versions" "versions" {}
