data "azurerm_resource_group" "main" {
  name = local.resource_group_name
}

data "azurerm_log_analytics_workspace" "shared" {
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_key_vault" "dxp-uks" {
  name                = "kv-uks-amaisdxp"
  resource_group_name = local.resource_group_name
}

data "azuread_group" "amais_app_umi" {
  display_name     = "Azure-RBAC-AMAIS-App-UMI"
  security_enabled = true
}

data "azuread_group" "dxp_developers" {
  display_name               = "Azure-RBAC-DXP-Developer"
  security_enabled           = true
  include_transitive_members = true
}

data "azurerm_subnet" "vnet_integration" {
  for_each = toset(local.dxp_regions)

  name                 = "subnet-${module.short_region_lookup[each.key].short_region}-dxp-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${module.short_region_lookup[each.key].short_region}-dxp-01"
  resource_group_name  = "rg-${module.short_region_lookup[each.key].short_region}-ubiq-networking"
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

data "azurerm_subnet" "hub_uksouth_tf" {
  name                 = "subnet-uks-terraform-agents-ci"
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
