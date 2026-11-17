locals {
  sub_id              = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  subnet_identifier   = element(split("-", local.sub_id), 0)
  resource_group_name = "Amais-DXP"
  st_name_01          = "amaisdxp"
  dxp_regions = [
    "uksouth",
    "centralus",
    "canadacentral",
    "germanywestcentral",
    "uaenorth"
  ]
  vnet_integration_subnet_ids = [for s in data.azurerm_subnet.vnet_integration : s.id]
  network_rulesets = {
    secure_access_gw_ip_addresses = [] # Twingate traffic should pass through subnet service endpoint
    vnet_integration_subnet_ids = concat(
      local.vnet_integration_subnet_ids,
      [
        data.azurerm_subnet.hub_centralindia_tg.id,
        data.azurerm_subnet.hub_uksouth_tg.id,
      ]
    )
  }
  diag_settings_name = "default_diagnostic_settings"
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
  }
}
