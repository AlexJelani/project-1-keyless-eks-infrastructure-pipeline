# GCP IAM Module
# Service account and Workload Identity Federation for GitHub Actions

locals {
  environment = var.environment != "" ? var.environment : "dev"
  pool_id     = "github-${local.environment}-${var.cluster_name}"
  provider_id = "github-${local.environment}"
}

# Service Account for GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = "github-actions-${local.environment}-${var.cluster_name}"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions to deploy to GKE"

  project = var.gcp_project_id
}

# Service Account IAM - Workload Identity User
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.pool_id}/attribute.repository/${var.github_owner}/${var.github_repository}"
}

# Workload Identity Federation Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = local.pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
  project                   = var.gcp_project_id
}

# OIDC Provider for GitHub Actions
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = local.provider_id
  display_name                       = "GitHub Provider"
  description                        = "GitHub Actions OIDC Provider"
  disabled                           = false

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "attribute.ref == 'refs/heads/${var.github_branch}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Bindings for the service account
resource "google_project_iam_member" "container_developer" {
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
  project = var.gcp_project_id
}

resource "google_project_iam_member" "artifactregistry_writer" {
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
  project = var.gcp_project_id
}

resource "google_project_iam_member" "logging_writer" {
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
  project = var.gcp_project_id
}

resource "google_project_iam_member" "monitoring_editor" {
  role    = "roles/monitoring.editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
  project = var.gcp_project_id
}

resource "google_project_iam_member" "service_account_user" {
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
  project = var.gcp_project_id
}
