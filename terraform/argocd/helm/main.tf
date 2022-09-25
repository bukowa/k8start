# main.tf

resource "random_password" "argo_password" {
  length = 16
  special = true
}

resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  name  = "argocd"
  version = "5.5.4"
  namespace = "argocd"
  create_namespace = true
  values = [
    file("values.yaml"),
  ]
  set {
    name = "configs.secret.argocdServerAdminPassword"
    value = random_password.argo_password.bcrypt_hash
  }
  wait_for_jobs = true
  timeout = 300
}

provider "helm" {
  kubernetes {
    host = local.cluster.host
    cluster_ca_certificate = base64decode(local.cluster.cluster_ca_certificate)
    token = local.cluster.token
    client_certificate = local.cluster.client_certificate
    client_key = local.cluster.client_key
  }
}
