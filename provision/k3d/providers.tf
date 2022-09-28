
provider "helm" {
  kubernetes {
    config_context = var.kube_config_context
    config_path = local.kube_config_path
  }
}

# https://registry.terraform.io/providers/oboukili/argocd/latest/docs
provider "argocd" {
  username = "admin"
  password = module.argocd.argo_password
  port_forward = true
  port_forward_with_namespace = "argocd"
  server_addr = "localhost:8080"
  kubernetes {
    config_path = local.kube_config_path
    config_context = var.kube_config_context
  }
}

terraform {
  required_providers {
    argocd = {
      source = "bukforks/argocd"
      version = "3.2.2-alpha"
    }
  }
}

