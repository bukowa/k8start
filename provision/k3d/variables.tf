
variable "cluster_name" {
  default = "k8start"
}

variable "kube_config_path" {
  default = ""
}

variable "kube_config_context" {
  default = "k3d-k8start"
}

locals {
  kube_config_path = (length(var.kube_config_path) > 0) ? pathexpand(var.kube_config_path) : pathexpand("~/.kube/configs/k3d")
}
