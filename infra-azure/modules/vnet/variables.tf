variable "vnet_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "CIDR block for the VNet"
}

variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name for resource naming"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}