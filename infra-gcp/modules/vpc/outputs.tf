output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "Self link of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in google_compute_subnetwork.private : s.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in google_compute_subnetwork.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in google_compute_subnetwork.private : s.id]
}

output "cloud_nat_ids" {
  description = "List of Cloud NAT IDs"
  value       = [for n in google_compute_router_nat.nat : n.id]
}

output "router_names" {
  description = "List of router names"
  value       = [for r in google_compute_router.router : r.name]
}