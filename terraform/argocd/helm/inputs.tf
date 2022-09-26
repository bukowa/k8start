# inputs.tf

variable "kube_config" {
}

variable "values" {
  default = []
  type = list(string)
}