module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.az_long_region
}

resource "random_id" "main" {
  byte_length = 16
}

module "avm-res-managedidentity-userassignedidentity-st" {
  for_each = local.environments

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-st-${local.st_name}${each.value.short_id}"
  resource_group_name = var.resource_group_name
  location            = var.az_long_region
  tags                = merge(local.tags, each.value.tags)
}

resource "azurerm_role_assignment" "main_st" {
  for_each = local.environments

  scope                = data.azurerm_key_vault.dxp.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-st[each.key].principal_id
}

resource "azurerm_key_vault_key" "main_st" {
  for_each = local.environments

  name            = "${local.st_name}${each.value.short_id}-key"
  key_vault_id    = data.azurerm_key_vault.dxp.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = merge(local.tags, each.value.tags)

  rotation_policy {
    expire_after         = "P1Y"
    notify_before_expiry = "P58D"
    automatic {
      time_before_expiry = "P60D"
    }
  }

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "time_sleep" "azurerm_key_vault_roles_keys" {
  create_duration = "60s"

  triggers = {
    kv_st_roles = join(",", values(azurerm_role_assignment.main_st)[*].id)
    kv_st_keys  = join(",", values(azurerm_key_vault_key.main_st)[*].id)
  }
}


module "avm-res-storage-storageaccount" {
  for_each = local.environments

  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = "${local.st_name}${each.value.short_id}"
  resource_group_name               = var.resource_group_name
  location                          = var.az_long_region
  account_kind                      = "StorageV2"
  account_replication_type          = "RAGZRS"
  account_tier                      = "Standard"
  access_tier                       = "Hot"
  min_tls_version                   = "TLS1_2"
  cross_tenant_replication_enabled  = false
  is_hns_enabled                    = false
  sftp_enabled                      = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  allowed_copy_scope                = "AAD"
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  queue_encryption_key_type         = "Account"
  table_encryption_key_type         = "Account"
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = false
  tags                              = merge(local.tags, each.value.tags, { data_classification = "confidential" }, { DrataExclude = "NotApplicable" })

  lock = var.add_delete_locks ? {
    name = "CanNotDelete"
    kind = "CanNotDelete"
  } : null

  network_rules = {
    bypass                     = var.network_rules_bypass_azure_services ? ["AzureServices"] : []
    default_action             = var.network_rules_default_action
    ip_rules                   = var.network_rules_ip_rules
    virtual_network_subnet_ids = var.network_rules_virtual_network_subnet_ids
  }

  share_properties = {
    retention_policy = {
      days = 7
    }
    smb = {
      authentication_types            = ["Kerberos"]
      channel_encryption_type         = ["AES-256-GCM"]
      kerberos_ticket_encryption_type = ["AES-256"]
      multichannel_enabled            = false
      versions                        = ["SMB3.1.1"]
    }
  }

  managed_identities = {
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-st[each.key].resource_id]
  }

  customer_managed_key = {
    key_vault_resource_id = data.azurerm_key_vault.dxp.id
    key_name              = azurerm_key_vault_key.main_st[each.key].name
    user_assigned_identity = {
      resource_id = module.avm-res-managedidentity-userassignedidentity-st[each.key].resource_id
    }
  }

  role_assignments = each.value.role_assignments != {} ? each.value.role_assignments : null

  depends_on = [
    time_sleep.azurerm_key_vault_roles_keys
  ]
}

resource "azapi_update_resource" "st_blob_properties" {
  for_each = local.environments

  type      = "Microsoft.Storage/storageAccounts/blobServices@2023-05-01"
  name      = "default"
  parent_id = module.avm-res-storage-storageaccount[each.key].resource.id
  body = {
    properties = {
      containerDeleteRetentionPolicy = {
        enabled = true
        days    = 7
      }
      deleteRetentionPolicy = {
        enabled = var.blob_delete_retention_policy.days == null ? false : true
        days    = var.blob_delete_retention_policy.days
      }
      isVersioningEnabled = var.blob_versioning_enabled
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  for_each = local.environments

  name                       = local.diag_settings_name
  target_resource_id         = join("", [module.avm-res-storage-storageaccount[each.key].resource.id, "/blobServices/default"])
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}
