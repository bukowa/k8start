# workaround that shouldn't be here
# https://github.com/argoproj/argo-helm/issues/1233#issuecomment-1106073583
resource "null_resource" "argocd_password" {
  triggers = {
    plain    = var.argo_password
    hash     = bcrypt(var.argo_password)
    modified = timestamp()
  }

  lifecycle {
    ignore_changes = [
      triggers["hash"],
      triggers["modified"]
    ]
  }
}

resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  name  = "argocd"
  version = "5.5.4"
  namespace = "argocd"
  create_namespace = true
  values = local.values

  set_sensitive {
    name = "configs.secret.argocdServerAdminPassword"
    value = null_resource.argocd_password.triggers.hash
  }

  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = null_resource.argocd_password.triggers.modified
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
