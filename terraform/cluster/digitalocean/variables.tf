
# should we save cluster config file?
variable "save_kube_config" {
  type = bool
  default = false
}

# where should we save it?
variable "kube_config_path" {
  type = string
  default = "~/.kube/configs/k8start"
}
