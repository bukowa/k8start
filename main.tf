resource "digitalocean_kubernetes_cluster" "k8s-starter" {
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

data "digitalocean_kubernetes_versions" "versions" {}
