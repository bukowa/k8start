terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      version = "~> 2.13.1"
    }
    helm = {
      version = "~> 2.6.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = "~> 3.2.1"
    }
  }
}

output "argopass" {
  value = local.argocdPass
  sensitive = true
}

locals {
  values = yamldecode(file("../../charts/web-digitalocean/values.yaml"))
  ingressValues = yamldecode(local.values["ingress"]["values"])
  kubeConfigPath = abspath(pathexpand("~/.kube/configs/k8start"))
  argocdPass = data.kubernetes_secret.argopass.data["password"]
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
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  name  = "argocd"
  version = "5.5.4"
  namespace = "argocd"
  create_namespace = true
  values = [
    file("values.yaml")
  ]
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
  depends_on = [helm_release.argocd]
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

provider "argocd" {
  username = "admin"
  password = local.argocdPass
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

resource "argocd_application" "starter" {
  wait = true
  timeouts {
    create = "30m"
  }
  metadata {
    name = "starter"
    namespace = "argocd"
  }
  spec {
    source {
      repo_url = "https://github.com/bukowa/k8start/"
      path = "charts/web-digitalocean"
      target_revision = "HEAD"
      helm {
        parameter {
          name = "http_check.parameters.host"
          value = "http2.devit.ovh"
        }
        parameter {
          name = "argocd_ingress.parameters.host"
          value = "arg3.devit.ovh"
        }
      }
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }
    sync_policy {
      automated = {
        self_heal = true
        prune = false
        allow_empty = false
      }
    }
  }
}

data "digitalocean_loadbalancer" "example" {
  depends_on = [argocd_application.starter]
  name = local.ingressValues["controller"]["service"]["annotations"]["service.beta.kubernetes.io/do-loadbalancer-name"]
}

data "digitalocean_domain" "default" {
  name = "devit.ovh"
}

resource "digitalocean_record" "default" {
  domain = data.digitalocean_domain.default.id
  type = "A"
  name = "*"
  ttl = 30
  value = data.digitalocean_loadbalancer.example.ip
}
