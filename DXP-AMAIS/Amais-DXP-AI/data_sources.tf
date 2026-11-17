data "azurerm_subscription" "current" {}

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

data "azurerm_subnet" "vnet_integration_ai_functions" {
  name                 = "subnet-uks-central-functions-02"
  virtual_network_name = "vnet-uks-amais-central-01"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_subnet" "vnet_integration" {
  for_each = toset(local.dxp_regions)

  name                 = "subnet-${module.short_region_lookup[each.key].short_region}-dxp-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${module.short_region_lookup[each.key].short_region}-dxp-01"
  resource_group_name  = "rg-${module.short_region_lookup[each.key].short_region}-ubiq-networking"
}
