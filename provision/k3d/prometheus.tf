
resource "helm_release" "prom_stack" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  name  = "promstack"
  version = "40.5.0"
  namespace = "logging"
  create_namespace = true
  values = [file(yamldecode("grafana.yaml"))]
  wait = true
  set {
    name = "grafana.ingress.enabled"
    value = "true"
  }
  set {
    name = "grafana.ingress.hosts[0]"
    value = "grafana.mydev"
  }
  set {
    name = "grafana.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name = "grafana.adminPassword"
    value = "admin"
  }
}
