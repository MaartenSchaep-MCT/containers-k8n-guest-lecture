variable "kube_context" {
  description = "kubectl context of your k3d cluster (see: kubectl config current-context)"
  type        = string
  default     = "k3d-k3s-default"
}

variable "repo_url" {
  description = "Your GitOps repo that Argo CD watches"
  type        = string
  default     = "https://github.com/MaartenSchaep-MCT/containers-k8n-guest-lecture" # <-- change
}
