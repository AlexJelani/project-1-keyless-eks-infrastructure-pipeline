# Backend configuration - stored in backend.hcl
# Example backend.hcl contents:
#   storage_account_name = "myterraformstate"
#   container_name       = "tfstate"
#   key                  = "keyless-aks/terraform.tfstate"
#   resource_group_name  = "my-rg"

terraform {
  backend "azurerm" {}
}
