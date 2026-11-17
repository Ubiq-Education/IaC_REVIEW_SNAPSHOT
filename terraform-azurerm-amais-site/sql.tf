resource "random_password" "sql_admin" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

module "avm-res-managedidentity-userassignedidentity-sql" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sql-${local.formatted_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = merge(var.tags, local.common_tags)
}

module "avm-res-managedidentity-userassignedidentity-sqldb" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-sqldb-${local.formatted_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = merge(var.tags, local.common_tags)
}

resource "azurerm_key_vault_key" "main_sql" {
  name            = "sql-${local.formatted_name}-key"
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

resource "azurerm_key_vault_key" "main_sqldb" {
  name            = "sqldb-${local.formatted_name}-key"
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

resource "azuread_group_member" "sql_entra_dir_r" {
  group_object_id  = data.azuread_group.entra_dir_r.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-sql.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azuread_group_member" "app_amais_sql_rw" {
  group_object_id  = data.azuread_group.amais_sql_rw.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_mssql_server" "main" {
  name                          = local.sql_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  administrator_login           = var.sql_admin_login
  administrator_login_password  = random_password.sql_admin.result
  minimum_tls_version           = "1.2"
  version                       = "12.0"
  public_network_access_enabled = true #tfsec:ignore:azure-database-no-public-access
  tags                          = merge(var.tags, local.common_tags, local.data_tags.confidential)

  azuread_administrator {
    login_username              = data.azuread_group.sql_admins.display_name
    object_id                   = data.azuread_group.sql_admins.object_id
    azuread_authentication_only = var.sql_entra_login_only
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sql.resource_id]
  }

  primary_user_assigned_identity_id            = module.avm-res-managedidentity-userassignedidentity-sql.resource_id
  transparent_data_encryption_key_vault_key_id = data.azurerm_key_vault_key.main_sql.id

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }

  depends_on = [time_sleep.azurerm_key_vault_key_all]
}

resource "time_sleep" "azurerm_mssql_server" {
  create_duration = "90s"

  depends_on = [azurerm_mssql_server.main]
}

resource "azapi_update_resource" "azurerm_mssql_server_main_encryption_protector" {
  type      = "Microsoft.Sql/servers/encryptionProtector@2023-08-01-preview"
  name      = "current"
  parent_id = azurerm_mssql_server.main.id
  body = {
    properties = {
      autoRotationEnabled = true
      serverKeyType       = "AzureKeyVault"
    }
  }
  depends_on = [time_sleep.azurerm_mssql_server]
}

resource "azurerm_mssql_virtual_network_rule" "main_vnet_amais" {
  name                                 = "Local-AMAIS-VNET"
  server_id                            = azurerm_mssql_server.main.id
  subnet_id                            = data.azurerm_subnet.vnet_integration.id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_mssql_firewall_rule" "main_custom" {
  for_each = var.sql_fw_rules

  name             = each.key
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address

  lifecycle {
    ignore_changes = [start_ip_address, end_ip_address]
  }
}

resource "azurerm_mssql_firewall_rule" "main_secure_access_gw" {
  for_each = module.ubiq_resources.secure_access_gw_pips

  name             = "Allow-${each.key}"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = each.value.ip_address
  end_ip_address   = each.value.ip_address
}

resource "azurerm_mssql_firewall_rule" "main_azure" {
  count = var.enable_sql_azure_firewall_exception ? 1 : 0

  name             = "AllowAllWindowsAzureIps"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "main" {
  name                 = local.sqldb_name
  server_id            = azurerm_mssql_server.main.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  sku_name             = var.sqldb_sku
  zone_redundant       = (upper(substr(var.sqldb_sku, 0, 1)) == "P" || upper(substr(var.sqldb_sku, 0, 2)) == "BC") && var.enable_zone_redundant_sql
  storage_account_type = "Geo"
  max_size_gb          = var.sqldb_max_size_gb
  tags                 = merge(var.tags, local.common_tags, local.data_tags.confidential)

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sqldb.resource_id]
  }

  transparent_data_encryption_key_vault_key_id               = data.azurerm_key_vault_key.main_sqldb.id
  transparent_data_encryption_key_automatic_rotation_enabled = true

  short_term_retention_policy {
    retention_days           = var.sqldb_pitr_days
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    monthly_retention = var.sqldb_monthly_retention
  }

  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]

    # Actions run in list order. provision_from_baseline waits for its pipeline run (wait_for_completion), so the
    # Baseline restore has finished before deploy_sql_dacpac is queued; deploy_sql_dacpac itself does not wait. With
    # var.provision_from_baseline false, provision_from_baseline is disabled (enabled in actions.tf) and does nothing.
    # No condition: from Terraform 1.16 a destroy plan evaluates the conditions of after_create triggers without the
    # variables they refer to, so a condition on var.provision_from_baseline fails every destroy with "Reference to
    # uninitialized variable". A destroy plan does not evaluate the actions' configuration.
    action_trigger {
      events = [after_create]
      actions = [
        action.azureactions_devops_pipeline_trigger.provision_from_baseline,
        action.azureactions_devops_pipeline_trigger.deploy_sql_dacpac,
      ]
    }
  }

  # Everything the after_create actions use must exist before they start: the provisioning pipeline reads the site's
  # AMAISSites entity (which references the storage account and its main container, so those exist too), reads the
  # one-off marker, connects to SQL from the DevOps agent pool, which the hub NAT gateway firewall rules allow, and
  # copies the Baseline's static website content into $web. $web only exists once the static website is enabled, and
  # the module's own $web files must be uploaded first: the pipeline never overwrites them, and Terraform cannot create
  # a blob that already exists. static_files depends on azurerm_storage_account_static_website.main.
  depends_on = [
    time_sleep.azurerm_key_vault_key_all,
    azurerm_storage_table_entity.amais_site,
    azurerm_mssql_firewall_rule.main_secure_access_gw,
    azurerm_storage_blob.static_files,
  ]
}

resource "azurerm_management_lock" "main_sqldb" {
  count      = var.add_delete_locks ? 1 : 0
  name       = "CanNotDelete"
  scope      = azurerm_mssql_database.main.id
  lock_level = "CanNotDelete"
  notes      = local.lock_note
}
