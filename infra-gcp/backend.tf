# Backend configuration - HCP Terraform remote backend
# Organization and workspace are set via environment variables:
#   TF_ORGANIZATION
#   TF_WORKSPACE
# Token is read from ~/.terraform.d/token

terraform {
  cloud {
    hostname = "app.terraform.io"
  }
}
