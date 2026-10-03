variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
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

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "container_registry_id" {
  type        = string
  description = "ID of the Container Registry"
}

variable "aks_cluster_id" {
  type        = string
  description = "ID of the AKS cluster"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}