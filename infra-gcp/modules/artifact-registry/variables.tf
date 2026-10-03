variable "repository_name" {
  type        = string
  description = "Artifact Registry repository name"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}