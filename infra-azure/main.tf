# Azure Infrastructure for Keyless EKS Migration
# Equivalent to AWS EKS setup but using Azure services

module "vnet" {
  source         = "./modules/vnet"
  vnet_cidr      = var.vnet_cidr
  azure_location = var.azure_location
  cluster_name   = var.cluster_name
  tags           = var.tags
}

module "aks" {
  source              = "./modules/aks"
  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  vnet_id             = module.vnet.vnet_id
  subnet_id           = module.vnet.aks_subnet_id
  azure_location      = var.azure_location
  resource_group_name = module.vnet.resource_group_name
  node_pool_sku       = var.node_pool_sku
  min_nodes           = var.min_nodes
  max_nodes           = var.max_nodes
  tags                = var.tags
}

module "container_registry" {
  source              = "./modules/container-registry"
  registry_name       = var.acr_repository_name
  resource_group_name = module.vnet.resource_group_name
  azure_location      = var.azure_location
  tags                = var.tags
}

module "iam" {
  source                = "./modules/iam"
  cluster_name          = var.cluster_name
  azure_subscription_id = var.azure_subscription_id
  azure_tenant_id       = var.azure_tenant_id
  resource_group_name   = module.vnet.resource_group_name
  github_owner          = var.github_owner
  github_repository     = var.github_repository
  github_branch         = var.github_branch
  container_registry_id = module.container_registry.acr_id
  aks_cluster_id        = module.aks.aks_id
  tags                  = var.tags
}
