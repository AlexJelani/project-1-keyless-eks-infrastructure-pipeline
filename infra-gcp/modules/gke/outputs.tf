output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "node_pool_name" {
  description = "Name of the GKE node pool"
  value       = google_container_node_pool.primary.name
}

output "cluster_location" {
  description = "GKE cluster location (region)"
  value       = google_container_cluster.primary.location
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}