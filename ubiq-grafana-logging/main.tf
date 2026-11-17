resource "random_id" "main" {
  for_each = local.regions

  byte_length = 16
}

module "short-region-lookup" {
  for_each = local.regions

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

resource "azurerm_resource_group" "main" {
  for_each = local.regions

  name     = "rg-${module.short-region-lookup[each.key].short_region}-${local.deployment_name}"
  location = each.key
  tags     = local.tags
}
