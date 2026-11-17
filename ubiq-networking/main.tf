module "short_region_lookup" {
  for_each = local.network_scheme

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

resource "azurerm_resource_group" "main" {
  for_each = local.network_scheme

  name     = "rg-${module.short_region_lookup[each.key].short_region}-ubiq-networking"
  location = each.key
  tags     = local.common_tags
}

module "regional_network" {
  for_each = local.network_scheme

  source              = "./modules/region_network"
  az_long_region      = each.key
  resource_group_name = azurerm_resource_group.main[each.key].name
  tags                = local.common_tags
  vnet_configurations = each.value.vnets
  diag_settings_name  = local.diag_settings_name
}
