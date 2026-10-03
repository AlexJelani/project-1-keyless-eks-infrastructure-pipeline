# Azure IAM Module
# Service Principal and Workload Identity Federation for GitHub Actions

locals {
  environment = var.environment != "" ? var.environment : "dev"
  pool_name   = "github-${local.environment}-${var.cluster_name}"
}

# Service Principal for GitHub Actions
resource "azuread_service_principal" "github_actions" {
  display_name                 = "github-actions-${local.environment}-${var.cluster_name}"
  app_role_assignment_required = false

  owners = [data.azuread_client_config.current.object_id]
}

# Service Principal client secret (for backward compatibility)
resource "azuread_service_principal_password" "github_actions" {
  service_principal_id = azuread_service_principal.github_actions.id
  end_date_relative    = "8760h" # 1 year
}

# GitHub Actions Workload Identity Federation Pool
resource "azuread_application_federated_identity_credential" "github" {
  display_name   = "github-${local.environment}"
  application_id = azuread_service_principal.github_actions.application_id
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
  audiences      = ["api://AzureADTokenExchange"]
  description    = "GitHub Actions federated credential for deployment"
}

# Role assignments for the service principal
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.github_actions.id
}

resource "azurerm_role_assignment" "aks_kube_admin" {
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.github_actions.id
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.github_actions.id
}

data "azuread_client_config" "current" {}
