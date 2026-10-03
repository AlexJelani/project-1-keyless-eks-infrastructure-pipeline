output "acr_id" {
  description = "ID of the ACR"
  value       = azurerm_container_registry.main.id
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_enabled" {
  description = "Whether admin is enabled"
  value       = azurerm_container_registry.main.admin_enabled
}
