variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name for pool ID"
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
  default     = {}
  description = "Resource tags"
}