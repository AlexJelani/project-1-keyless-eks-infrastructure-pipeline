output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.aks_name
}

output "aks_cluster_endpoint" {
  description = "AKS cluster endpoint"
  value       = module.aks.aks_endpoint
}

output "aks_cluster_ca_certificate" {
  description = "AKS cluster CA certificate"
  value       = module.aks.aks_ca_certificate
  sensitive   = true
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.container_registry.acr_login_server
}

output "aks_resource_group" {
  description = "AKS resource group name"
  value       = module.vnet.resource_group_name
}

output "aks_node_pool_name" {
  description = "Name of the AKS node pool"
  value       = module.aks.node_pool_name
}

output "aks_node_resource_group" {
  description = "AKS node resource group name"
  value       = module.aks.node_resource_group
}

output "vnet_id" {
  description = "VNet ID"
  value       = module.vnet.vnet_id
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL"
  value       = module.aks.aks_oidc_issuer_url
  sensitive   = false
}
