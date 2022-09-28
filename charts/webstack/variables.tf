
variable "source_repo_url" {
  default = "https://github.com/bukowa/k8start.git"
}

variable "source_path" {
  default = "charts/webstack"
}

variable "source_target_revision" {
  default = "HEAD"
}

variable "destination_server" {
  default = "https://kubernetes.default.svc"
}
variable "destination_namespace" {
  default = "webstack"
}
