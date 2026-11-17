module "short_region_lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = local.az_region
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${module.short_region_lookup.short_region}-dxp-client-resources"
  location = local.az_region
  tags     = local.common_tags
}

resource "azuread_group" "dxp_umi" {
  display_name     = "Azure-RBAC-DXP-App-UMI"
  security_enabled = true
  mail_enabled     = false
  description      = "All DXP web app priamry user managed identities, populated by Terraform"
}
