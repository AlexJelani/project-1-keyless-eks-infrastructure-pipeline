# Backend configuration - HCP Terraform remote backend
# Update with your Terraform Cloud organization and workspace names

terraform {
  backend "http" {
    # These values are set via CLI or environment variables
    # terraform login and terraform init -backend-config=backend.hcl

    # organization = "your-org"        # Set via env var: TF_VAR_organization
    # workspaces {
    #   name = "keyless-eks-infra"     # Set via env var: TF_WORKSPACE
    # }
  }
}
