# resource "random_password" "sql_admin" {
#   length           = 20
#   special          = true
#   override_special = "!#$%&*()-_+[]{}<>:?"
#   min_lower        = 2
#   min_upper        = 2
#   min_numeric      = 2
#   min_special      = 2
# }

module "short_region_lookup" {
  for_each = toset(local.dxp_regions)

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

module "avm-res-managedidentity-userassignedidentity-sql-uks" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sql-uks-amais-dxp"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.common_tags
}

module "avm-res-managedidentity-userassignedidentity-sqldb-uks" {
  for_each = local.dxp_sql_dtu_dbs_uks

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = lower("id-sqldb-uks-${each.key}")
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.common_tags
}

resource "time_sleep" "azurerm_managedidentity_sql" {
  create_duration = "60s"

  triggers = {
    sql_id    = module.avm-res-managedidentity-userassignedidentity-sql-uks.resource_id
    sqldb_ids = join(",", values(module.avm-res-managedidentity-userassignedidentity-sqldb-uks)[*].resource_id)
  }
}

resource "azurerm_role_assignment" "sql_uks_st" {
  scope                = data.azurerm_storage_account.uks_dxp.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-sql-uks.principal_id

  depends_on = [time_sleep.azurerm_managedidentity_sql]
}

resource "azurerm_role_assignment" "sql_uks_kv" {
  scope                = data.azurerm_key_vault.dxp["uksouth"].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-sql-uks.principal_id

  depends_on = [time_sleep.azurerm_managedidentity_sql]
}

resource "azurerm_role_assignment" "sqldb_uks_kv" {
  for_each = local.dxp_sql_dtu_dbs_uks

  scope                = data.azurerm_key_vault.dxp["uksouth"].id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-sqldb-uks[each.key].principal_id

  depends_on = [time_sleep.azurerm_managedidentity_sql]
}

resource "time_sleep" "kv_rbac" {
  create_duration = "90s"

  triggers = {
    sql_id    = azurerm_role_assignment.sql_uks_kv.id
    sqldb_ids = join(",", values(azurerm_role_assignment.sqldb_uks_kv)[*].id)
  }
}

resource "azurerm_key_vault_secret" "sql_uks_admin_password" {
  name         = "sql-uks-amais-dxp-superadmin-secret"
  key_vault_id = data.azurerm_key_vault.dxp["uksouth"].id
  value        = var.sql_uks_admin_password
  tags         = local.common_tags
}

resource "azurerm_key_vault_key" "main_sql_uks" {
  name            = "sql-uks-amais-dxp-key"
  key_vault_id    = data.azurerm_key_vault.dxp["uksouth"].id
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

resource "azurerm_key_vault_key" "main_sqldb_uks" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name            = lower("sqldb-uks-${each.key}-key")
  key_vault_id    = data.azurerm_key_vault.dxp["uksouth"].id
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

resource "time_sleep" "azurerm_key_vault_key_sql" {
  create_duration = "90s"

  triggers = {
    key_main_sql_uks_id   = azurerm_key_vault_key.main_sql_uks.id
    key_main_sqldb_uks_id = join(",", values(azurerm_key_vault_key.main_sqldb_uks)[*].id)
  }
}

resource "azuread_group_member" "sql_uks_entra_dir_r" {
  group_object_id  = data.azuread_group.entra_dir_r.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-sql-uks.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_sql]
}

resource "azurerm_mssql_server" "uks" {
  name                         = "amais-dxp"
  resource_group_name          = data.azurerm_resource_group.main.name
  location                     = data.azurerm_resource_group.main.location
  administrator_login          = "superadmin"
  administrator_login_password = var.sql_uks_admin_password
  minimum_tls_version          = "1.2"
  version                      = "12.0"
  tags                         = merge(local.common_tags, local.data_tags.confidential)

  azuread_administrator {
    login_username              = data.azuread_group.sql_admins.display_name
    object_id                   = data.azuread_group.sql_admins.object_id
    azuread_authentication_only = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sql-uks.resource_id]
  }

  primary_user_assigned_identity_id            = module.avm-res-managedidentity-userassignedidentity-sql-uks.resource_id
  transparent_data_encryption_key_vault_key_id = data.azurerm_key_vault_key.main_sql_uks.id

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }

  depends_on = [time_sleep.azurerm_key_vault_key_sql, time_sleep.kv_rbac]
}

resource "time_sleep" "azurerm_mssql_server" {
  create_duration = "90s"

  depends_on = [azurerm_mssql_server.uks]
}

resource "azapi_update_resource" "azurerm_mssql_server_uks_encryption_protector" {
  type      = "Microsoft.Sql/servers/encryptionProtector@2023-08-01-preview"
  name      = "current"
  parent_id = azurerm_mssql_server.uks.id
  body = {
    properties = {
      autoRotationEnabled = true
      serverKeyType       = "AzureKeyVault"
    }
  }
  depends_on = [time_sleep.azurerm_mssql_server]
}

resource "azurerm_mssql_server_extended_auditing_policy" "uks" {
  server_id                       = azurerm_mssql_server.uks.id
  enabled                         = true
  log_monitoring_enabled          = false
  storage_endpoint                = data.azurerm_storage_account.uks_dxp.primary_blob_endpoint
  storage_account_subscription_id = local.sub_id
  retention_in_days               = 90
}

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "uks" {
  server_id                       = azurerm_mssql_server.uks.id
  enabled                         = true
  log_monitoring_enabled          = false
  blob_storage_endpoint           = data.azurerm_storage_account.uks_dxp.primary_blob_endpoint
  storage_account_subscription_id = local.sub_id
}

resource "azurerm_mssql_virtual_network_rule" "uks_vnet_dxp" {
  name                                 = "Local-DXP-VNET"
  server_id                            = azurerm_mssql_server.uks.id
  subnet_id                            = data.azurerm_subnet.vnet_integration["uksouth"].id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_mssql_firewall_rule" "uks_secure_access_gw" {
  count = length(data.azurerm_public_ip.secure_access_gw_pips)

  name             = "Allow-${data.azurerm_public_ip.secure_access_gw_pips[count.index].name}"
  server_id        = azurerm_mssql_server.uks.id
  start_ip_address = data.azurerm_public_ip.secure_access_gw_pips[count.index].ip_address
  end_ip_address   = data.azurerm_public_ip.secure_access_gw_pips[count.index].ip_address
}

resource "azurerm_mssql_database" "uks" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name                 = each.key
  server_id            = azurerm_mssql_server.uks.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = each.value.sku_name
  zone_redundant       = false
  storage_account_type = "Geo"
  max_size_gb          = each.value.max_size_gb
  tags                 = merge(local.common_tags, local.data_tags.confidential)

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sqldb-uks[each.key].resource_id]
  }

  transparent_data_encryption_key_vault_key_id               = data.azurerm_key_vault_key.main_sqldb_uks[each.key].id
  transparent_data_encryption_key_automatic_rotation_enabled = true

  short_term_retention_policy {
    # Basic tier supports at most 7 days and Azure resets higher values back to 7
    retention_days           = each.value.sku_name == "Basic" ? 7 : 14
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    monthly_retention = "P6M"
  }

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }

  depends_on = [time_sleep.azurerm_key_vault_key_sql, time_sleep.kv_rbac]
}

resource "azurerm_management_lock" "uks_sqldb" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name       = "CanNotDelete"
  scope      = azurerm_mssql_database.uks[each.key].id
  lock_level = "CanNotDelete"
  notes      = local.lock_note
}
