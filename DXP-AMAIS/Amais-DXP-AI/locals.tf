locals {
  subnet_identifier = element(split("-", data.azurerm_subscription.current.subscription_id), 0)
  dxp_regions = [
    "uksouth",
    "centralus",
    "canadacentral",
    "germanywestcentral",
    "uaenorth"
  ]
  vnet_integration_subnet_ids = [for s in data.azurerm_subnet.vnet_integration : s.id]
}
