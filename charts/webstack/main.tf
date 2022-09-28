
resource "argocd_application" "starter" {
  wait = true
  timeouts {
    create = "5m"
  }
  metadata {
    name = "webstack"
    namespace = "argocd"
  }
  spec {
    source {
      repo_url = var.source_repo_url
      path = var.source_path
      target_revision = var.source_target_revision
    }
    destination {
      server    = var.destination_server
      namespace = var.destination_namespace
    }
    sync_policy {
      automated = {
        self_heal = true
        prune = false
        allow_empty = false
      }
    }
  }
}
