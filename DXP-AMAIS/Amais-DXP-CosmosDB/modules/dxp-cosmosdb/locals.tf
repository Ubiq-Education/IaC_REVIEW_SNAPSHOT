locals {
  azure_tenant_id              = data.azurerm_client_config.current.tenant_id
  subnet_identifier            = element(split("-", data.azurerm_subscription.current.subscription_id), 0)
  short_region                 = module.short_region_lookup[var.az_long_region].short_region
  diag_settings_name           = "default_diagnostic_settings"
  ubiq_action_group_rg         = "rg-uks-ubiq-shared-res"
  formatted_name               = lower("${local.short_region}-amais-dxp")
  cosmosdb_name                = "coscas-${local.formatted_name}"
  log_analytics_workspace_name = "log-uks-ubiq-shared-logging"
  log_analytics_workspace_rg   = "rg-uks-ubiq-shared-logging"
  key_vault_name               = "kv-${local.short_region}-amaisdxp"
  key_vault_rg                 = "Amais-DXP"
  dxp_regions = [
    "uksouth",
    "centralus",
    "canadacentral",
    "germanywestcentral",
    "uaenorth"
  ]
}
