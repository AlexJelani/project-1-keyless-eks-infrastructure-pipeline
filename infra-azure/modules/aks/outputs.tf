output "aks_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_endpoint" {
  description = "AKS cluster endpoint"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "aks_ca_certificate" {
  description = "Base64 encoded CA certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "node_pool_name" {
  description = "Name of the AKS node pool"
  value       = azurerm_kubernetes_cluster.main.default_node_pool[0].name
}

output "node_resource_group" {
  description = "AKS node resource group name"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "aks_service_principal_object_id" {
  description = "Service principal object ID"
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}
