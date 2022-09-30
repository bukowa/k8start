
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
  values = local.values
  set {
    name = "configs.secret.argocdServerAdminPassword"
    value = random_password.argo_password.bcrypt_hash
  }
  dynamic "set" {
    for_each = var.set
    content {
      name = set.value["name"]
      value = set.value["value"]
      type = set.value["type"]
    }
  }
}
