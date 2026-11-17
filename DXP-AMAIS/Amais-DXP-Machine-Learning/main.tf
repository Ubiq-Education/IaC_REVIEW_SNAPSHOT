resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-appi-${local.deployment_name}"
  resource_group_name = lower(data.azurerm_resource_group.main.name) # Force lower due to random case change being detected
  location            = local.az_long_region
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_application_insights" "main" {
  name                          = "appi-${local.deployment_name}"
  resource_group_name           = data.azurerm_resource_group.main.name
  location                      = local.az_long_region
  workspace_id                  = azurerm_log_analytics_workspace.main.id
  application_type              = "web"
  local_authentication_disabled = false #TODO: Disable this
  retention_in_days             = 90
  sampling_percentage           = 0
  tags                          = local.common_tags
}

######

module "avm-res-managedidentity-userassignedidentity-st" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = local.st_id_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.az_long_region
  tags                = local.common_tags
}

module "avm-res-managedidentity-userassignedidentity-mlw" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = local.mlw_id_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.az_long_region
  tags                = local.common_tags
}

module "avm-res-managedidentity-userassignedidentity-mlw-comp" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = local.mlw_comp_id_name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.az_long_region
  tags                = local.common_tags
}

resource "time_sleep" "azurerm_userassignedidentity_all" {
  create_duration = "60s"

  triggers = {
    mi_st_id       = module.avm-res-managedidentity-userassignedidentity-st.resource_id
    mi_mlw_id      = module.avm-res-managedidentity-userassignedidentity-mlw.resource_id
    mi_mlw_comp_id = module.avm-res-managedidentity-userassignedidentity-mlw-comp.resource_id
  }
}

resource "azurerm_role_assignment" "main_st_kv" {
  scope                = data.azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-st.principal_id

  depends_on = [time_sleep.azurerm_userassignedidentity_all]
}

resource "azurerm_role_assignment" "main_mlw_rg" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-mlw.principal_id

  depends_on = [time_sleep.azurerm_userassignedidentity_all]
}

resource "azurerm_key_vault_key" "main_st" {
  name            = "${local.st_name}-key"
  key_vault_id    = data.azurerm_key_vault.main.id
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

resource "time_sleep" "azurerm_key_vault_all" {
  create_duration = "90s"

  triggers = {
    key_main_st_id = azurerm_key_vault_key.main_st.id
    role_st_kv_id  = azurerm_role_assignment.main_st_kv.id
  }
}

module "avm-res-storage-storageaccount" {
  source                            = "Azure/avm-res-storage-storageaccount/azurerm"
  version                           = "~>0.6.9"
  enable_telemetry                  = false
  name                              = local.st_name
  resource_group_name               = data.azurerm_resource_group.main.name
  location                          = local.az_long_region
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
    cors_rule = [
      {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "HEAD", "PUT", "DELETE", "OPTIONS", "POST", "PATCH"]
        allowed_origins = [
          "https://mlworkspace.azure.ai",
          "https://ml.azure.com",
          "https://*.ml.azure.com",
          "https://ai.azure.com",
          "https://*.ai.azure.com"
        ]
        exposed_headers    = ["*"]
        max_age_in_seconds = 1800
      }
    ]
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
    cors_rule = [
      {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "HEAD", "PUT", "DELETE", "OPTIONS", "POST"]
        allowed_origins = [
          "https://mlworkspace.azure.ai",
          "https://ml.azure.com",
          "https://*.ml.azure.com",
          "https://ai.azure.com",
          "https://*.ai.azure.com"
        ]
        exposed_headers    = ["*"]
        max_age_in_seconds = 1800
      }
    ]
  }

  managed_identities = {
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-st.resource_id]
  }

  customer_managed_key = {
    key_vault_resource_id = data.azurerm_key_vault.main.id
    key_name              = azurerm_key_vault_key.main_st.name
    user_assigned_identity = {
      resource_id = module.avm-res-managedidentity-userassignedidentity-st.resource_id
    }
  }

  role_assignments = {
    mlw_comp_blobs = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-mlw-comp.principal_id
    }
    mlw_blobs = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-mlw.principal_id
    }
    ai_dev_blobs = {
      role_definition_id_or_name = "Storage Blob Data Contributor"
      principal_id               = local.azure_rbac_ai_developer_group_object_id
    }
    mlw_files = {
      role_definition_id_or_name = "Storage File Data Privileged Contributor"
      principal_id               = module.avm-res-managedidentity-userassignedidentity-mlw.principal_id
    }
    ai_dev_files = {
      role_definition_id_or_name = "Storage File Data Privileged Contributor"
      principal_id               = local.azure_rbac_ai_developer_group_object_id
      #
    }
  }

  depends_on = [
    time_sleep.azurerm_key_vault_all
  ]
}

resource "azurerm_machine_learning_workspace" "main" {
  name                           = local.deployment_name
  location                       = local.az_long_region
  resource_group_name            = data.azurerm_resource_group.main.name
  friendly_name                  = local.deployment_name
  sku_name                       = "Basic"
  application_insights_id        = azurerm_application_insights.main.id
  key_vault_id                   = data.azurerm_key_vault.main.id
  storage_account_id             = module.avm-res-storage-storageaccount.resource_id
  container_registry_id          = data.azurerm_container_registry.main.id
  public_network_access_enabled  = true
  primary_user_assigned_identity = module.avm-res-managedidentity-userassignedidentity-mlw.resource_id
  tags                           = local.common_tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.avm-res-managedidentity-userassignedidentity-mlw.resource_id
    ]
  }
}
