
variable "save_kube_config" {
  type = bool
  default = true
  description = "if true kubernetes config file will be saved to `kube_config_path`"
}

variable "kube_config_path" {
  type = string
  default = "~/.kube/configs/k8start"
  description = "path where kubernetes config will be saved if `save_kube_config` is `true`"
}
