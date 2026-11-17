# blob_storage_endpoint and storage_endpoint properties should be gauranteed to be valid due to the variable validations and data source conditions

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "main" {
  for_each = var.mssql.mssql_server_ids

  server_id                       = provider::azurerm::normalise_resource_id(each.value)
  enabled                         = var.mssql.mssql_server_microsoft_support_auditing_enabled
  log_monitoring_enabled          = false
  blob_storage_endpoint           = data.azurerm_storage_account.sql_auditing[0].primary_blob_endpoint
  storage_account_subscription_id = local.sql_auditing_sa.id["subscription_id"]
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  for_each = var.mssql.mssql_server_ids

  server_id                       = provider::azurerm::normalise_resource_id(each.value)
  enabled                         = var.mssql.mssql_server_auditing_enabled
  log_monitoring_enabled          = false
  storage_endpoint                = data.azurerm_storage_account.sql_auditing[0].primary_blob_endpoint
  storage_account_subscription_id = local.sql_auditing_sa.id["subscription_id"]
  retention_in_days               = var.mssql.auditing_retention_in_days
}

resource "azurerm_mssql_database_extended_auditing_policy" "main" {
  for_each = var.mssql.mssql_database_ids

  database_id            = provider::azurerm::normalise_resource_id(each.value)
  enabled                = var.mssql.mssql_database_auditing_enabled
  log_monitoring_enabled = false
  storage_endpoint       = data.azurerm_storage_account.sql_auditing[0].primary_blob_endpoint
  retention_in_days      = var.mssql.auditing_retention_in_days
}
