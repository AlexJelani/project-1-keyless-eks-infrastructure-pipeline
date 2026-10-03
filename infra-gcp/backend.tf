# Backend configuration - stored in backend.hcl
# Example backend.hcl contents:
#   bucket         = "my-terraform-state-bucket"
#   prefix         = "keyless-eks/terraform.tfstate"
#   project        = "my-gcp-project"
#   region         = "us-central1"

terraform {
  backend "gcs" {}
}
