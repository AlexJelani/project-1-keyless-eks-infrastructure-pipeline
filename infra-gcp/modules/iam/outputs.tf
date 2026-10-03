output "service_account_email" {
  description = "Service account email for GitHub Actions"
  value       = google_service_account.github_actions.email
}

output "service_account_name" {
  description = "Service account name"
  value       = google_service_account.github_actions.name
}

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
}

output "workload_identity_pool_name" {
  description = "Workload Identity Pool name"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "service_account_iam_member_role" {
  description = "Role binding for service account"
  value       = "roles/iam.workloadIdentityUser"
}