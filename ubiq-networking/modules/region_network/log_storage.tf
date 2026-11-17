resource "random_id" "main" {
  byte_length = 16
}

resource "azurerm_key_vault_key" "main_st" {
  name            = "${local.st_name}-key"
  key_vault_id    = data.azurerm_key_vault.shared.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = var.tags

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

module "avm-res-managedidentity-userassignedidentity-st" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = local.st_id_name
  resource_group_name = var.resource_group_name
  location            = var.az_long_region
  tags                = var.tags
}

resource "time_sleep" "azurerm_key_vault_all" {
  create_duration = "90s"

  triggers = {
    key_main_st_id = azurerm_key_vault_key.main_st.id
    kv_id_role     = module.avm-res-managedidentity-userassignedidentity-st.resource_id
  }
}

resource "azurerm_role_assignment" "st_kv_crypto" {
  scope                = data.azurerm_key_vault.shared.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-st.principal_id

  depends_on = [time_sleep.azurerm_key_vault_all]
}

module "avm-res-storage-storageaccount" {
  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = local.st_name
  resource_group_name               = var.resource_group_name
  location                          = var.az_long_region
  account_kind                      = "StorageV2"
  account_replication_type          = local.az_region_zones == 0 ? "LRS" : "ZRS"
  account_tier                      = "Standard"
  access_tier                       = "Hot"
  min_tls_version                   = "TLS1_2"
  cross_tenant_replication_enabled  = false
  is_hns_enabled                    = false
  sftp_enabled                      = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  allowed_copy_scope                = "AAD"
  shared_access_key_enabled         = true
  default_to_oauth_authentication   = true
  queue_encryption_key_type         = "Account"
  table_encryption_key_type         = "Account"
  public_network_access_enabled     = true
  allow_nested_items_to_be_public   = false
  tags                              = merge({ usage = "flow_logs_only" }, var.tags, { data_classification = "confidential" }, { DrataExclude = "NotApplicable" })

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Deny"
    virtual_network_subnet_ids = [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id
    ]
  }

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
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-st.resource_id]
  }

  customer_managed_key = {
    key_vault_resource_id = data.azurerm_key_vault.shared.id
    key_name              = azurerm_key_vault_key.main_st.name
    user_assigned_identity = {
      resource_id = module.avm-res-managedidentity-userassignedidentity-st.resource_id
    }
  }

  depends_on = [azurerm_role_assignment.st_kv_crypto]
}
