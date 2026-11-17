resource "azurerm_resource_group" "main" {
  name     = "rg-${var.deployment_name}-shared"
  location = local.primary_region.name
  tags     = local.merged_tags
}

module "avm-res-keyvault-vault" {
  for_each = toset(var.regions)

  source                          = "Azure/avm-res-keyvault-vault/azurerm"
  version                         = "~>0.12.0"
  enable_telemetry                = false
  name                            = "kv-${module.short-region-lookup-additional[each.key].short_region}-ai-${lower(substr(random_id.main.hex, 0, 4))}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = each.key
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  sku_name                        = "standard"
  tags                            = local.merged_tags

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "main_kv" {
  for_each = toset(var.regions)

  name                       = local.diag_settings_name
  target_resource_id         = module.avm-res-keyvault-vault[each.key].resource_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}
