data "azurerm_log_analytics_workspace" "shared" {
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_key_vault" "dxp" {
  name                = "kv-${local.short_region}-amaisdxp"
  resource_group_name = local.kv_rg
}
