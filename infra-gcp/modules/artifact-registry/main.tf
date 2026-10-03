# GCP Artifact Registry Module
# Equivalent to AWS ECR

resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = var.repository_name
  location      = var.region
  description   = "Docker repository for container images"
  format        = "DOCKER"

  project = var.project_id
}
