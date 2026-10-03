# GCP Infrastructure for Keyless EKS Migration
# Equivalent to AWS EKS setup but using GCP services

module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  region       = var.region
  cluster_name = var.cluster_name
  project_id   = var.gcp_project_id
  tags         = var.tags
}

module "gke" {
  source             = "./modules/gke"
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  region             = var.region
  project_id         = var.gcp_project_id
  machine_type       = var.node_pool_machine_type
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes
  tags               = var.tags
}

module "artifact_registry" {
  source          = "./modules/artifact-registry"
  repository_name = var.artifact_registry_repo
  region          = var.region
  project_id      = var.gcp_project_id
  tags            = var.tags
}

module "iam" {
  source            = "./modules/iam"
  cluster_name      = var.cluster_name
  gcp_project_id    = var.gcp_project_id
  github_owner      = var.github_owner
  github_repository = var.github_repository
  github_branch     = var.github_branch
  tags              = var.tags
}
