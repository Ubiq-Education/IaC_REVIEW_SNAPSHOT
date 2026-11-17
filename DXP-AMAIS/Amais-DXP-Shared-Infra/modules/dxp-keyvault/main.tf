module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.az_long_region
}

module "avm-res-keyvault-vault" {
  source                          = "Azure/avm-res-keyvault-vault/azurerm"
  version                         = "~>0.12.0"
  enable_telemetry                = false
  name                            = "kv-${module.short-region-lookup.short_region}-amaisdxp"
  resource_group_name             = var.resource_group_name
  location                        = var.az_long_region
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  sku_name                        = "standard"
  tags                            = local.tags
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = var.network_acl_default_action
    virtual_network_subnet_ids = var.network_acl_subnet_ids
  }
  role_assignments = {
    main_kv_tf_secrets_officer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    main_kv_tf_crypto_officer = {
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = local.diag_settings_name
  target_resource_id         = module.avm-res-keyvault-vault.resource_id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}

resource "azurerm_management_lock" "main" {
  name       = "CanNotDelete"
  scope      = module.avm-res-keyvault-vault.resource_id
  lock_level = "CanNotDelete"
  notes      = local.lock_note

  depends_on = [
    module.avm-res-keyvault-vault, azurerm_monitor_diagnostic_setting.main
  ]
}
