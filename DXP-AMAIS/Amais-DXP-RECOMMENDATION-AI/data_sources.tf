data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "main" {
  name = "Amais-DXP"
}

data "azurerm_storage_account" "main" {
  name                = "amaisdxp"
  resource_group_name = "Amais-DXP"
}

data "azurerm_log_analytics_workspace" "shared" {
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_subnet" "vnet_integration" {
  name                 = "subnet-${local.short_region}-dxp-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${local.short_region}-dxp-01"
  resource_group_name  = "rg-${local.short_region}-ubiq-networking"
}

data "azurerm_subnet" "hub_centralindia_tg" {
  name                 = "subnet-inc-twingate-ci"
  virtual_network_name = "vnet-inc-hub"
  resource_group_name  = "rg-inc-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_tg" {
  name                 = "subnet-uks-twingate-ci"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_devops_01" {
  name                 = "subnet-uks-devops-agent-pool-01"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_devops_02" {
  name                 = "subnet-uks-devops-agent-pool-02"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azuread_group" "dxp_app_umi" {
  display_name     = "Azure-RBAC-DXP-App-UMI"
  security_enabled = true
}
