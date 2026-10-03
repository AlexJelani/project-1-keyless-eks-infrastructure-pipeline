# Backend configuration - HCP Terraform remote backend
# Organization and workspace are set via environment variables:
#   TF_CLOUD_ORGANIZATION
#   TF_WORKSPACE_NAME
# Token is read from ~/.terraform.d/config.hcl

terraform {
  cloud {
    organization = "alexander-tech-inc"

    workspaces {
      name = "keyless-eks-infra-gcp"
    }
  }
}
