
variable "kube_config_path" {
  default = ""
}

locals {
  kube_config_path = (length(var.kube_config_path) > 0) ? var.kube_config_path : pathexpand("~/.kube/configs/k3d")
}
