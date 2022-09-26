module "argocd" {
  depends_on = [null_resource.sd]
  source = "../modules/argocd/helm"
  values = [
    file("../modules/argocd/helm/values.yaml"),
    file("argocd.helm.values.yaml"),
  ]
}

provider "helm" {
  kubernetes {
    config_context = "k3d-k8start"
    config_path = local.kube_config_path
  }
}

resource "null_resource" "sd" {
  provisioner "local-exec" {
    when = create
    interpreter = ["bash", "-c"]
    command = "KUBECONFIG='${local.kube_config_path}' k3d cluster create k8start --servers=3 --k3s-arg='--disable=traefik@server:*' -p '80:80@loadbalancer' -p '443:443@loadbalancer' --verbose"
  }
  provisioner "local-exec" {
    when = destroy
    interpreter = ["bash", "-c"]
    command = "k3d cluster delete k8start"
  }
}

resource "helm_release" "nginx" {
  depends_on = [null_resource.sd]
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  name  = "ingress-nginx"
  wait_for_jobs = true
}

output "argo_password" {
  value = module.argocd.argo_password
  sensitive = true
}
