locals {
  values = yamldecode(file("${path.module}/values.yaml"))
  ingressValues = yamldecode(local.values["ingress"]["values"])
  kubeConfigPath = abspath(pathexpand("~/.kube/configs/k8start"))
}

data "digitalocean_kubernetes_versions" "versions" {}

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

resource "local_sensitive_file" "kube_config" {
  filename = local.kubeConfigPath
  content = digitalocean_kubernetes_cluster.starter.kube_config[0].raw_config
}

provider "helm" {
  kubernetes {
    host = digitalocean_kubernetes_cluster.starter.kube_config[0].host
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.starter.kube_config[0].cluster_ca_certificate)
    token = digitalocean_kubernetes_cluster.starter.kube_config[0].token
    client_certificate = digitalocean_kubernetes_cluster.starter.kube_config[0].client_certificate
    client_key = digitalocean_kubernetes_cluster.starter.kube_config[0].client_key
  }
}

resource "helm_release" "argocd" {
  depends_on = [digitalocean_kubernetes_cluster.starter]
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  name  = "argocd"
  version = "5.5.4"
  namespace = "argocd"
  create_namespace = true
  values = []
  wait_for_jobs = true
  timeout = 300
}

provider kubernetes {
  host = digitalocean_kubernetes_cluster.starter.kube_config[0].host
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.starter.kube_config[0].cluster_ca_certificate)
  token = digitalocean_kubernetes_cluster.starter.kube_config[0].token
  client_certificate = digitalocean_kubernetes_cluster.starter.kube_config[0].client_certificate
  client_key = digitalocean_kubernetes_cluster.starter.kube_config[0].client_key
}

data "kubernetes_secret" "argopass" {
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  binary_data = {
    "password" = ""
  }
}

provider "argocd" {
  username = "admin"
  password = base64decode(data.kubernetes_secret.argopass.binary_data.password)
  port_forward = true
  port_forward_with_namespace = "argocd"
  server_addr = "localhost:8080"
  kubernetes {
    host = digitalocean_kubernetes_cluster.starter.kube_config[0].host
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.starter.kube_config[0].cluster_ca_certificate)
    token = digitalocean_kubernetes_cluster.starter.kube_config[0].token
    client_certificate = digitalocean_kubernetes_cluster.starter.kube_config[0].client_certificate
    client_key = digitalocean_kubernetes_cluster.starter.kube_config[0].client_key
  }
}

resource "argocd_application" "test" {
  depends_on = [helm_release.argocd]

  wait = true
  timeouts {
    create = "10m"
  }
  metadata {
    name = "test"
    namespace = "argocd"
  }
  spec {
    project = "default"
    source {
      repo_url = "https://github.com/bukowa/k8start.git"
      path = "."
      target_revision = "HEAD"
    }
    destination {
      server = "https://kubernetes.default.svc"
      namespace = "argocd"
    }
    sync_policy {
      automated = {
        self_heal = true
      }
    }
  }
}