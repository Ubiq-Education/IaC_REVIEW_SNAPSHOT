module "avm-res-managedidentity-userassignedidentity-st" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-st-${local.formatted_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = merge(var.tags, local.common_tags)
}

resource "azurerm_key_vault_key" "main_st" {
  name            = "${local.st_name}-key"
  key_vault_id    = module.avm-res-keyvault-vault.resource_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = merge(var.tags, local.common_tags)

  rotation_policy {
    expire_after         = "P1Y"
    notify_before_expiry = "P28D"
    automatic {
      time_before_expiry = "P30D"
    }
  }

  lifecycle {
    ignore_changes = [expiration_date]
  }

  depends_on = [time_sleep.kv]
}

module "avm-res-storage-storageaccount" {
  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.8.0"
  enable_telemetry                  = false
  name                              = local.st_name
  parent_id                         = azurerm_resource_group.main.id
  location                          = azurerm_resource_group.main.location
  account_kind                      = "StorageV2"
  account_sku_name                  = local.az_region_zones == 0 ? "Standard_RAGRS" : "Standard_RAGZRS"
  account_tier                      = "Standard"
  access_tier                       = "Hot"
  min_tls_version                   = "TLS1_2"
  cross_tenant_replication_enabled  = false
  is_hns_enabled                    = false
  sftp_enabled                      = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  allowed_copy_scope                = "AAD"
  shared_access_key_enabled         = var.enable_storage_shared_key_access
  default_to_oauth_authentication   = true
  queue_encryption_key_type         = "Account"
  table_encryption_key_type         = "Account"
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = var.allow_public_blobs
  tags                              = merge(var.tags, local.common_tags, local.data_tags.public)

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

  file_service_properties = {
    share_retention_policy = {
      days    = 30
      enabled = true
    }
    smb = {
      authentication_types            = ["Kerberos"]
      channel_encryption_type         = ["AES-256-GCM"]
      kerberos_ticket_encryption_type = ["AES-256"]
      versions                        = ["SMB3.1.1"]
    }
  }

  managed_identities = {
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-st.resource_id]
  }

  containers = {
    main_priv = {
      name          = lower(var.site_name)
      public_access = "None"
    }
  }

  depends_on = [time_sleep.azurerm_key_vault_key_all]
}

resource "azurerm_storage_account_customer_managed_key" "main" {
  storage_account_id        = module.avm-res-storage-storageaccount.resource.id
  key_vault_key_id          = azurerm_key_vault_key.main_st.versionless_id
  user_assigned_identity_id = module.avm-res-managedidentity-userassignedidentity-st.resource_id
}

resource "azurerm_role_assignment" "main_st_app_blob_contributor" {
  scope                = module.avm-res-storage-storageaccount.resource.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_role_assignment" "main_st_sql_blob_contributor" {
  scope                = module.avm-res-storage-storageaccount.resource.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-sql.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_storage_account_static_website" "main" {
  storage_account_id = module.avm-res-storage-storageaccount.resource.id
  error_404_document = "error.html"
  index_document     = "index.html"
}

resource "azurerm_storage_management_policy" "main" {
  storage_account_id = module.avm-res-storage-storageaccount.resource.id

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

resource "azurerm_storage_container" "additional_containers" {
  for_each              = local.additional_storage_containers_map
  name                  = each.value.name
  storage_account_id    = module.avm-res-storage-storageaccount.resource_id
  container_access_type = each.value.access_type
}

resource "azurerm_storage_blob" "static_files" {
  for_each = local.staticweb_files

  name                 = each.value.name
  storage_container_id = "${module.avm-res-storage-storageaccount.resource_id}/blobServices/default/containers/$web"
  type                 = "Block"
  source_content       = data.http.staticweb_files[each.key].response_body
  content_type         = each.value.type

  depends_on = [azurerm_storage_account_static_website.main]
}

resource "azurerm_storage_container" "dxp_ai" {
  provider              = azurerm.shared
  name                  = lower(local.amais_application_name)
  storage_account_id    = data.azurerm_storage_account.uks_dxp.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "main_app_dxp_blob_data_contributor" {
  provider             = azurerm.shared
  scope                = azurerm_storage_container.dxp_ai.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}
