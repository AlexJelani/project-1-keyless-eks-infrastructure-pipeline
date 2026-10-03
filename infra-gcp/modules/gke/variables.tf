variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Kubernetes version for the cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "machine_type" {
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

variable "service_account_email" {
  type        = string
  default     = ""
  description = "Service account email for nodes (optional, uses default if empty)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}