
resource "argocd_application" "pyroscope" {
  metadata {
    name      = "pyroscope"
    namespace = "argocd" # The namespace where Argo CD itself is installed
  }

  spec {
    project = argocd_project.pyroscope.metadata[0].name

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "observability"
    }

    source {
      repo_url        = "https://grafana.github.io/helm-charts"
      chart           = "pyroscope"
      target_revision = "1.15.1"

      helm {
        release_name = "pyroscope"
        values       = file("${path.module}/files/pyroscope-values.yaml")
      }
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }

      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }
}

