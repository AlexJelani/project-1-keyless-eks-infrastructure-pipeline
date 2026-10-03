# GCP VPC Module
# Equivalent to AWS VPC with public/private subnets and Cloud NAT

locals {
  # Use availability zones with fallback to us-central1-a/b/c if not provided
  azs = var.availability_zones
}

resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  project = var.project_id
}

resource "google_compute_subnetwork" "public" {
  for_each      = toset(local.azs)
  name          = "${var.cluster_name}-public-${each.key}"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, index(local.azs, each.key))
  region        = var.region
  network       = google_compute_network.vpc.self_link

  purpose = "PUBLIC_ROUTES"

  project = var.project_id
}

resource "google_compute_subnetwork" "private" {
  for_each                 = toset(local.azs)
  name                     = "${var.cluster_name}-private-${each.key}"
  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 8, index(local.azs, each.key) + 10)
  region                   = var.region
  network                  = google_compute_network.vpc.self_link
  private_ip_google_access = true

  project = var.project_id
}

resource "google_compute_router" "router" {
  for_each = toset(local.azs)
  name     = "${var.cluster_name}-router-${each.key}"
  region   = var.region
  network  = google_compute_network.vpc.self_link

  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  for_each                           = toset(local.azs)
  name                               = "${var.cluster_name}-nat-${each.key}"
  region                             = var.region
  router                             = google_compute_router.router[each.key].name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  project = var.project_id
}
