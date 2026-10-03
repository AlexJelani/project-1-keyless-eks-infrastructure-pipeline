# Backend configuration - HCP Terraform remote backend
# Organization and workspace are set via environment variables:
#   TF_VAR_organization (or TF_ORGANIZATION)
#   TF_WORKSPACE

terraform {
  backend "http" {}
}
