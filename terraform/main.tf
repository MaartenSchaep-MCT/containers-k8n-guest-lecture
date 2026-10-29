# 1. Argo CD itself (replaces your manual "helm install argocd ...")
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  # version        = "x.y.z"   # optional: pin a version from artifacthub.io

  wait    = true
  timeout = 900 # first image pulls are slow on k3d
}

# 2. The "root" app of apps (replaces your manual "kubectl apply -f bootstrap/root.yaml")
#    The argocd-apps chart just turns these values into Argo CD Application objects.
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"

  values = [yamlencode({
    applications = {
      root = {
        namespace = "argocd"
        project   = "default"
        source = {
          repoURL        = var.repo_url
          targetRevision = "main"
          path           = "apps"
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "argocd"
        }
        syncPolicy = {
          automated = { prune = true, selfHeal = true }
        }
      }
    }
  })]

  # Argo CD (and its Application CRD) must exist first
  depends_on = [helm_release.argocd]
}
