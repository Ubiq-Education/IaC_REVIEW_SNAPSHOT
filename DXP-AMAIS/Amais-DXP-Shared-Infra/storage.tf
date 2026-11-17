## New storage accounts
module "dxp_storage_processor" {
  source                     = "./modules/dxp-storage"
  subscription_id            = local.sub_id
  az_long_region             = "uksouth"
  resource_group_name        = "Amais-DXP"
  storage_purpose_short_name = "processor"
  staging_role_assignments = {
    "Azure-RBAC-DXP-Developer-SBDC" = {
      principal_id = "2c32d842-d28a-4e4a-b602-2d0d763edc56"
      role_name    = "Storage Blob Data Contributor"
    }
  }
  network_rules_virtual_network_subnet_ids = concat(
    [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ],
    local.vnet_integration_subnet_ids
  )
}

## Legacy storage accounts

module "avm-res-managedidentity-userassignedidentity-main-st-uks" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-st-uks-${local.st_name_01}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "main_st_uks_kv" {
  scope                = data.azurerm_key_vault.dxp-uks.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-main-st-uks.principal_id
}

resource "time_sleep" "azurerm_key_vault_role" {
  create_duration = "60s"

  triggers = {
    kv_st_role = azurerm_role_assignment.main_st_uks_kv.id
  }
}

resource "azurerm_key_vault_key" "main_st_uks" {
  name            = "st-uks-${local.st_name_01}-key"
  key_vault_id    = data.azurerm_key_vault.dxp-uks.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = local.common_tags

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

module "avm-res-storage-storageaccount-main-uks" {
  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = local.st_name_01
  resource_group_name               = data.azurerm_resource_group.main.name
  location                          = data.azurerm_resource_group.main.location
  account_kind                      = "StorageV2"
  account_replication_type          = "ZRS"
  account_tier                      = "Standard"
  access_tier                       = "Hot"
  min_tls_version                   = "TLS1_2"
  cross_tenant_replication_enabled  = false
  is_hns_enabled                    = false
  sftp_enabled                      = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = false
  allowed_copy_scope                = "AAD"
  shared_access_key_enabled         = true # FIXME: Cannot lockdown due to Elastic snapshots
  default_to_oauth_authentication   = true
  queue_encryption_key_type         = "Service"
  table_encryption_key_type         = "Service"
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = false
  tags                              = merge(local.common_tags, { data_classification = "confidential" }, { DrataExclude = "NotApplicable" })

  network_rules = null

  blob_properties = {
    container_delete_retention_policy = {
      days = 7
    }
    delete_retention_policy = {
      days = 7
    }
    versioning_enabled = false
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
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-main-st-uks.resource_id]
  }

  customer_managed_key = {
    key_vault_resource_id = data.azurerm_key_vault.dxp-uks.id
    key_name              = azurerm_key_vault_key.main_st_uks.name
    user_assigned_identity = {
      resource_id = module.avm-res-managedidentity-userassignedidentity-main-st-uks.resource_id
    }
  }

  role_assignments = {
    amais_umi_blob_delegator = {
      role_definition_id_or_name = "Storage Blob Delegator"
      principal_id               = data.azuread_group.amais_app_umi.object_id
    }
  }

  depends_on = [time_sleep.azurerm_key_vault_role]
}

resource "azurerm_monitor_diagnostic_setting" "main_st_uks_blob" {
  name                       = local.diag_settings_name
  target_resource_id         = join("", [module.avm-res-storage-storageaccount-main-uks.resource.id, "/blobServices/default"])
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}

resource "azurerm_monitor_diagnostic_setting" "main_st_uks_file" {
  name                       = local.diag_settings_name
  target_resource_id         = join("", [module.avm-res-storage-storageaccount-main-uks.resource.id, "/fileServices/default"])
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}
