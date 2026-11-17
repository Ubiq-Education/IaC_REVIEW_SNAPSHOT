module "short_region_lookup" {
  for_each = toset(local.dxp_regions)

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}
