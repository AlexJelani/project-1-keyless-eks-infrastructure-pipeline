# Azure Container Registry Module
# Equivalent to AWS ECR

resource "azurerm_container_registry" "main" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  sku                 = "Basic"
  admin_enabled       = false

  tags = var.tags
}
