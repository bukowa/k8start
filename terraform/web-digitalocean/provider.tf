terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {}
    helm = {}
    argocd = {
      source = "oboukili/argocd"
      version = "~> 3.2.1"
    }
  }
}
