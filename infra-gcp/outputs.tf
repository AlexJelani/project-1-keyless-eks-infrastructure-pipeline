output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
}

output "gke_cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = module.artifact_registry.repository_url
}

output "service_account_email" {
  description = "Service account email for GitHub Actions"
  value       = module.iam.service_account_email
  sensitive   = false
}

output "workload_identity_pool_id" {
  description = "Workload Identity Pool ID"
  value       = module.iam.workload_identity_pool_id
}

output "gke_node_pool_name" {
  description = "Name of the GKE node pool"
  value       = module.gke.node_pool_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
