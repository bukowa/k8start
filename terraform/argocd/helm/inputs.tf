# inputs.tf

variable "cluster_state" {
  default = "../../cluster/digitalocean/terraform.tfstate"
}

data "terraform_remote_state" "cluster" {
  backend = "local"
  config = {
    path = var.cluster_state
  }
}

locals {
  cluster = data.terraform_remote_state.cluster.outputs.kube_config
}
