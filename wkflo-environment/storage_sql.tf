resource "random_id" "sql" {
  for_each = var.regions_enabled

  byte_length = 16
}

module "avm-res-storage-storageaccount-sql-auditlogs" {
  for_each = var.regions_enabled

  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = "st${lower(substr(random_id.sql[each.key].hex, 0, 22))}"
  resource_group_name               = azurerm_resource_group.main[each.key].name
  location                          = azurerm_resource_group.main[each.key].location
  account_kind                      = "StorageV2"
  account_replication_type          = "ZRS"
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
  tags                              = merge(local.tags, local.data_tags.confidential)

  lock = var.add_delete_locks ? {
    name = "CanNotDelete"
    kind = "CanNotDelete"
  } : null

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    virtual_network_subnet_ids = distinct(compact(concat(
      [for subnet in module.ubiq_resources.twingate_subnets : subnet.id],
      [for subnet in module.ubiq_resources.terraform_subnets : subnet.id]
    )))
  }

  blob_properties = {
    container_delete_retention_policy = {
      days = 180
    }
    delete_retention_policy = {
      days = 180
    }
  }

  share_properties = {
    retention_policy = {
      days = 30
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
    key_vault_resource_id = module.key_vault[each.key].id
    key_name              = module.key_vault[each.key].keys["st_cmk"].name
    user_assigned_identity = {
      resource_id = module.avm-res-managedidentity-userassignedidentity-st[each.key].resource_id
    }
  }

  role_assignments = {
    main_st_sql_blob_contributor = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-sql[each.key].principal_id
    }
  }
}

resource "azurerm_storage_management_policy" "sql_auditlogs" {
  for_each = var.regions_enabled

  storage_account_id = module.avm-res-storage-storageaccount-sql-auditlogs[each.key].resource.id

  rule {
    enabled = true
    name    = "BlobVersionRetention"
    actions {
      version {
        delete_after_days_since_creation = 180
      }
    }
    filters {
      blob_types = ["blockBlob", "appendBlob"]
    }
  }
  rule {
    enabled = true
    name    = "SQLAuditLogs"
    actions {
      version {
        delete_after_days_since_creation = 1
      }
    }
    filters {
      blob_types   = ["blockBlob", "appendBlob"]
      prefix_match = ["sqldbauditlogs/"]
    }
  }
}
