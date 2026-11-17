resource "azuread_group_member" "sql_entra_dir_r" {
  for_each = var.regions_enabled

  group_object_id  = data.azuread_group.entra_dir_r.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-sql[each.key].principal_id

  depends_on = [time_sleep.azurerm_userassignedidentity_all]
}

resource "azurerm_mssql_server" "main" {
  for_each = var.regions_enabled

  name                = "sql-${local.cae_names[each.key]}"
  location            = azurerm_resource_group.main[each.key].location
  resource_group_name = azurerm_resource_group.main[each.key].name
  minimum_tls_version = "1.2"
  version             = "12.0"
  tags                = merge(local.tags, local.data_tags.confidential)

  azuread_administrator {
    login_username              = data.azuread_group.sql_admins.display_name
    object_id                   = data.azuread_group.sql_admins.object_id
    azuread_authentication_only = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sql[each.key].resource_id]
  }

  primary_user_assigned_identity_id            = module.avm-res-managedidentity-userassignedidentity-sql[each.key].resource_id
  transparent_data_encryption_key_vault_key_id = module.key_vault[each.key].keys["sql_tde"].id

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }
}

resource "time_sleep" "sql" {
  create_duration = "90s"

  triggers = {
    for k, v in azurerm_mssql_server.main : k => v.id
  }
}

resource "azapi_update_resource" "sql_encryption_protector" {
  for_each = var.regions_enabled

  type      = "Microsoft.Sql/servers/encryptionProtector@2023-08-01-preview"
  name      = "current"
  parent_id = azurerm_mssql_server.main[each.key].id
  body = {
    properties = {
      autoRotationEnabled = true
      serverKeyType       = "AzureKeyVault"
    }
  }

  depends_on = [time_sleep.sql]
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  for_each = var.regions_enabled

  server_id              = azurerm_mssql_server.main[each.key].id
  enabled                = true
  log_monitoring_enabled = false
  storage_endpoint       = module.avm-res-storage-storageaccount-sql-auditlogs[each.key].resource.primary_blob_endpoint
  retention_in_days      = 90
}

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "main" {
  for_each = var.regions_enabled

  server_id              = azurerm_mssql_server.main[each.key].id
  enabled                = true
  log_monitoring_enabled = false
  blob_storage_endpoint  = module.avm-res-storage-storageaccount-sql-auditlogs[each.key].resource.primary_blob_endpoint
}

resource "azurerm_mssql_virtual_network_rule" "cae" {
  for_each = var.regions_enabled

  name                                 = "cae-vnet"
  server_id                            = azurerm_mssql_server.main[each.key].id
  subnet_id                            = module.regional_network[each.key].subnets["wkflo-01:cae-01"].id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_mssql_firewall_rule" "secure_access_gw" {
  for_each = local.region_secure_access_gw_pips_map

  name             = "Allow-${each.value.name}"
  server_id        = azurerm_mssql_server.main[split("-", each.key)[0]].id
  start_ip_address = each.value.ip_address
  end_ip_address   = each.value.ip_address
}

resource "azurerm_mssql_database" "main" {
  for_each = local.region_sqldb_map

  # if each.value.name starts with sqldb-, use it as is, otherwise prefix with sqldb- to create the name
  name                 = startswith(each.value.name, "sqldb-") ? each.value.name : "sqldb-${each.value.name}"
  server_id            = azurerm_mssql_server.main[each.value.region].id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = each.value.sku_name
  zone_redundant       = false
  storage_account_type = "Geo"
  max_size_gb          = each.value.max_size_gb
  tags                 = merge(local.tags, local.data_tags.confidential)

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sqldb[each.value.region].resource_id]
  }

  transparent_data_encryption_key_vault_key_id               = module.key_vault[each.value.region].keys["sqldb_tde"].id
  transparent_data_encryption_key_automatic_rotation_enabled = true

  short_term_retention_policy {
    retention_days           = 14
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    monthly_retention = "P6M"
  }

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }
}

resource "azurerm_management_lock" "sqldb" {
  for_each = local.region_sqldb_map

  name       = "CanNotDelete"
  scope      = azurerm_mssql_database.main[each.key].id
  lock_level = "CanNotDelete"
  notes      = local.lock_note
}
