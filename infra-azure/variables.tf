variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Azure region for resources"
}

variable "cluster_name" {
  type        = string
  default     = "keyless-aks"
  description = "Name of the AKS cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Kubernetes version for the cluster"
}

variable "vnet_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "CIDR block for the VNet"
}

variable "node_pool_sku" {
  type        = string
  default     = "Standard_DS2_v2"
  description = "VM size for AKS nodes"
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

variable "acr_repository_name" {
  type        = string
  default     = "keylessaksapp"
  description = "Azure Container Registry repository name"
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
  default     = { Project = "keyless-aks", ManagedBy = "terraform" }
  description = "Resource tags"
}
