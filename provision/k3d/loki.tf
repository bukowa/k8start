
resource "helm_release" "loki" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "loki-distributed"
  name  = "loki"
  version = "0.74.2"
  namespace = "logging"
  create_namespace = true
  wait = true
}
