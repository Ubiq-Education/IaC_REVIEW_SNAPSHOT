data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_monitor_action_group" "ubiq_warning" {
  name                = "UBIQWarning"
  resource_group_name = local.ubiq_action_group_rg
}

data "azurerm_log_analytics_workspace" "shared" {
  name                = local.log_analytics_workspace_name
  resource_group_name = local.log_analytics_workspace_rg
}

data "azurerm_key_vault" "main" {
  name                = local.key_vault_name
  resource_group_name = local.key_vault_rg
}

data "azurerm_subnet" "secure_access_centralindia" {
  name                 = "subnet-inc-twingate-ci"
  virtual_network_name = "vnet-inc-hub"
  resource_group_name  = "rg-inc-ubiq-networking"
}

data "azurerm_subnet" "secure_access_uksouth" {
  name                 = "subnet-uks-twingate-ci"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_subnet" "vnet_integration" {
  for_each = toset(local.dxp_regions)

  name                 = "subnet-${module.short_region_lookup[each.key].short_region}-dxp-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${module.short_region_lookup[each.key].short_region}-dxp-01"
  resource_group_name  = "rg-${module.short_region_lookup[each.key].short_region}-ubiq-networking"
}
