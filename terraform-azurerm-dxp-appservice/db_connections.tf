locals {
  db_connection_sql_db_name_staging = (
    var.db_connection_sql_db_name_staging_override != null ? var.db_connection_sql_db_name_staging_override : "${var.db_connection_sql_db_name}-STAGING"
  )
  db_connection_string_serverauth = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=${var.db_connection_sql_db_name};",
    "Persist Security Info=False;",
    "User ID=superadmin;",
    "Password=${data.azurerm_key_vault_secret.amais_dxp_superadmin_secret.value};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.db_connection_sql_db_name_max_pool_size};"
  ])
  db_connection_string_entra = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=${var.db_connection_sql_db_name};",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.db_connection_sql_db_name_max_pool_size};"
  ])
  db_connection_string_staging_serverauth = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=${local.db_connection_sql_db_name_staging};",
    "Persist Security Info=False;",
    "User ID=superadmin;",
    "Password=${data.azurerm_key_vault_secret.amais_dxp_superadmin_secret.value};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.db_connection_sql_db_name_max_pool_size_staging};"
  ])
  db_connection_string_staging_entra = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=${local.db_connection_sql_db_name_staging};",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.db_connection_sql_db_name_max_pool_size_staging};"
  ])
  nlog_db_connection_string_serverauth = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-LOGGING;",
    "Persist Security Info=False;",
    "User ID=superadmin;",
    "Password=${data.azurerm_key_vault_secret.amais_dxp_superadmin_secret.value};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  nlog_db_connection_string_entra = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-LOGGING;",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  nlog_db_connection_string_staging_serverauth = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-STAGING-LOGGING;",
    "Persist Security Info=False;",
    "User ID=superadmin;",
    "Password=${data.azurerm_key_vault_secret.amais_dxp_superadmin_secret.value};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  nlog_db_connection_string_staging_entra = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-STAGING-LOGGING;",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  analytics_connection_string_serverauth = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-ANALYTICS;",
    "Persist Security Info=False;",
    "User ID=superadmin;",
    "Password=${data.azurerm_key_vault_secret.amais_dxp_superadmin_secret.value};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.analytics_db_connection_sql_db_name_max_pool_size};"
  ])
  analytics_connection_string_entra = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-ANALYTICS;",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.analytics_db_connection_sql_db_name_max_pool_size};"
  ])
  analytics_connection_string_staging_serverauth = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-ANALYTICS-STAGING;",
    "Persist Security Info=False;",
    "User ID=superadmin;",
    "Password=${data.azurerm_key_vault_secret.amais_dxp_superadmin_secret.value};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.analytics_db_connection_sql_db_name_max_pool_size_staging};"
  ])
  analytics_connection_string_staging_entra = join("", [
    "Server=tcp:${var.db_connection_sql_server_fqdn},1433;",
    "Initial Catalog=AMAIS-DXP-ANALYTICS-STAGING;",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app-staging.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;",
    "Max Pool Size=${var.analytics_db_connection_sql_db_name_max_pool_size_staging};"
  ])
}
