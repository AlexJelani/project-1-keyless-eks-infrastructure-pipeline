output "service_principal_id" {
  description = "Service Principal ID"
  value       = azuread_service_principal.github_actions.id
}

output "service_principal_app_id" {
  description = "Service Principal Application ID"
  value       = azuread_service_principal.github_actions.application_id
}

output "service_principal_object_id" {
  description = "Service Principal Object ID"
  value       = azuread_service_principal.github_actions.id
}

output "federated_credential_id" {
  description = "Federated Identity Credential ID"
  value       = azuread_application_federated_identity_credential.github.id
}
