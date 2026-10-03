variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region for resources"
}

variable "cluster_name" {
  type        = string
  default     = "keyless-eks"
  description = "Name of the GKE cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Kubernetes version for the cluster"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "CIDR block for the VPC"
}

variable "node_pool_machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Machine type for GKE nodes"
}

variable "min_nodes" {
  type        = number
  default     = 2
  description = "Minimum number of nodes in the node pool"
}

variable "max_nodes" {
  type        = number
  default     = 4
  description = "Maximum number of nodes in the node pool"
}

variable "artifact_registry_repo" {
  type        = string
  default     = "keyless-eks-app"
  description = "Artifact Registry repository name"
}

variable "github_owner" {
  type        = string
  description = "GitHub organization or user"
}

variable "github_repository" {
  type        = string
  description = "Repository name without owner"
}

variable "github_branch" {
  type        = string
  default     = "main"
  description = "GitHub branch for OIDC"
}

variable "tags" {
  type        = map(string)
  default     = { Project = "keyless-eks", ManagedBy = "terraform" }
  description = "Resource tags"
}
