resource "kubernetes_manifest" "application_argocd_webstack" {
  wait {
    fields = {
      "status.health.status" = "Healthy"
      "status.resources[0].health.status" = "Healthy"
      "status.resources[1].health.status" = "Healthy"
    }
  }
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind" = "Application"
    "metadata" = {
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io",
      ]
      "name" = "webstack"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "server" = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "helm" = {
          "parameters" = [
            {
              "name" = "ingress.provider"
              "value" = "k3d"
            },
          ]
        }
        "path" = "charts/webstack"
        "repoURL" = "https://github.com/bukowa/k8start.git"
        "targetRevision" = "0.1.0"
      }
      "syncPolicy" = {
        "automated" = {
          "allowEmpty" = false
          "prune" = false
          "selfHeal" = true
        }
        "syncOptions" = [
          "CreateNamespace=true",
        ]
      }
    }
  }
}
