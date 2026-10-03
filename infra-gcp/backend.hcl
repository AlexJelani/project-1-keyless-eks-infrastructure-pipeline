# Backend configuration - HCP Terraform remote backend
# State is managed by Terraform Cloud workspace: keyless-eks-infra-gcp

terraform {
  backend "http" {}
}
