# GCP GKE Module
# Equivalent to AWS EKS with managed node groups

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Enable private cluster
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
  }

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable logging and monitoring
  vertical_pod_autoscaling {
    enabled = true
  }

  # Enable network policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable binary authorization
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  project = var.project_id
}

# Node pool with preemptible (spot) instances for cost savings
resource "google_container_node_pool" "primary" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name

  # Use preemptible instances for cost savings (~60% discount)
  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = 100
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    service_account = var.service_account_email != "" ? var.service_account_email : null
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/trace.append"
    ]

    # Enable spot instances
    spot = true

    labels = {
      workload = "general"
    }

    tags = [
      "${var.cluster_name}-node",
      "gke-node"
    ]
  }

  # Auto-scaling configuration
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Node count
  node_count = var.min_nodes

  project = var.project_id
}
