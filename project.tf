
resource "argocd_project" "pyroscope" {
  metadata {
    name      = "pyroscope"
    namespace = "argocd" # The namespace where Argo CD itself is installed
  }

  spec {
    description       = "Project for Loki applications"
    source_namespaces = ["*"]
    source_repos      = ["*"]
    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "observability"
    }
  }
}
