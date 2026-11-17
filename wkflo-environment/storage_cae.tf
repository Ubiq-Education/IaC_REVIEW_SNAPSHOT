module "avm-res-storage-storageaccount" {
  for_each = var.regions_enabled

  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = "st${lower(substr(random_id.main[each.key].hex, 0, 22))}"
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

  network_rules = null

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

  role_assignments = local.is_staging ? {
    developer_st_blob_contributor = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = data.azuread_group.devs.object_id
    }
  } : {}
}

resource "azurerm_storage_account_static_website" "main" {
  for_each = var.regions_enabled

  storage_account_id = module.avm-res-storage-storageaccount[each.key].resource.id
  error_404_document = "error.html"
  index_document     = "index.html"
}

resource "azurerm_storage_blob" "static_files" {
  for_each = local.region_staticweb_files_map

  name                 = each.value.name
  storage_container_id = "${module.avm-res-storage-storageaccount[each.value.region].resource.id}/blobServices/default/containers/$web"
  type                 = "Block"
  source_content       = data.http.staticweb_files[each.value.file_key].response_body
  content_type         = each.value.type

  depends_on = [azurerm_storage_account_static_website.main]
}

resource "azurerm_storage_management_policy" "main" {
  for_each = var.regions_enabled

  storage_account_id = module.avm-res-storage-storageaccount[each.key].resource.id

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
