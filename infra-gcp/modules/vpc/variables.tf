variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "CIDR block for the VPC"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name for resource naming"
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

variable "availability_zones" {
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
  description = "Availability zones for subnets"
}
