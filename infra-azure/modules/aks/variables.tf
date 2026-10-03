variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Kubernetes version for the cluster"
}

variable "vnet_id" {
  type        = string
  description = "ID of the VNet"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
}

variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}