
locals {
  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
  # we use `yamldecode` here so it's possible to read these values in terraform
  argocd_helm_values = yamldecode(file("argocd.yaml"))
}


module "argocd" {
  depends_on = [null_resource.k3d_cluster]
  source = "../argocd/helm"
  values = [
    file("../argocd/helm/values.yaml"),
    yamlencode(local.argocd_helm_values)
  ]
}
