
variable "values" {
  default = []
  type = list(string)
  description = "values passed to argocd helm release, for more see helm provider doc"
}
