
resource "helm_release" "promtail" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "promtail"
  name  = "promtail"
  version = "6.4.0"
  namespace = "logging"
  create_namespace = true
  wait = true
  set {
    name = "config.clients[0].url"
    value = "http://loki-loki-distributed-gateway/loki/api/v1/push"
  }
}
