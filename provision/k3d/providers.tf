
provider "helm" {
  kubernetes {
    config_context = var.kube_config_context
    config_path = local.kube_config_path
  }
}

provider "kubernetes" {
  config_path = local.kube_config_path
}

terraform {
  required_providers {
    kubernetes = {
      version = "~> 2.13.1"
    }
    helm = {
      version = "~> 2.7.0"
    }
  }

}
