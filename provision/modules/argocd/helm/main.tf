
resource "random_password" "argo_password" {
  length = 16
  special = true
}

locals {
  values = (length(var.values) > 0) ? var.values : [file("${path.module}/values.yaml")]
}

resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  name  = "argocd"
  version = "5.5.4"
  namespace = "argocd"
  create_namespace = true
  values = local.values
  set {
    name = "configs.secret.argocdServerAdminPassword"
    value = random_password.argo_password.bcrypt_hash
  }
}
