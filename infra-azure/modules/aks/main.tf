# Azure AKS Module
# Equivalent to AWS EKS with managed node pools

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name = "systempool"
    node_labels = {
      workload = "general"
    }

    enable_auto_scaling = true
    min_count           = var.min_nodes
    max_count           = var.max_nodes

    # Use spot instances for cost savings
    enable_spot_node = true
    spot_max_price   = -1

    # VM size
    vm_size = var.node_pool_sku

    # Temporary disk settings
    temporary_disk_settings {
      storage_type = "Local"
    }

    # Kubernetes network configuration
    vnet_subnet_id = var.subnet_id
    type           = "Managed"
    os_type        = "Linux"
    os_sku         = "Ubuntu"

    # Enable HTTPS
    enable_https_tls = true
  }

  # Identity configuration
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = "kubenet"
    network_policy    = "calico"
    outbound_type     = "loadBalancer"
    load_balancer_sku = "standard"
  }

  # RBAC configuration
  role_based_access_control {
    enabled = true
  }

  # Add-ons
  oms_agent {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  # Kubernetes dashboard
  key_vault_secrets_provider {
    enabled = true
  }

  tags = var.tags
}

# Log Analytics workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.cluster_name}-law"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# Log Analytics solution for AKS
resource "azurerm_log_analytics_solution" "aks_monitoring" {
  solution_name         = "ContainerInsights"
  location              = var.azure_location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
