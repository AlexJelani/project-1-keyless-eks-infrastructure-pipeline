variable "registry_name" {
  type        = string
  description = "Azure Container Registry name (must be unique)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}