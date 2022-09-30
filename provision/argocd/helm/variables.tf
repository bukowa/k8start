
variable "values" {
  default = []
  type = list(string)
  description = "values passed to argocd helm release, for more see helm provider doc"
}

variable "set" {
  type = list(object({
    name = string,
    value = string,
    type = string,
  }))
  default = []
}

locals {
  values = (length(var.values) > 0) ? var.values : [file("${path.module}/values.yaml")]
}
