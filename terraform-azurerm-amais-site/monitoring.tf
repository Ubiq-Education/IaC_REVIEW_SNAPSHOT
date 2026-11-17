resource "time_sleep" "diagnostics_migration" {
  # Quick fix to ensure old diagnostic settings are removed before new ones are applied to avoid conflicts.
  # Can be removed in the future when the old diagnostic settings are fully removed from the environment.
  create_duration = "120s"
}

module "monitoring_diagnostics" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.3"
  diagnostics_destinations = {
    event_hub = {
      enabled               = true
      eventhub_namespace_id = "/subscriptions/da462007-44f7-4547-ab47-679054904e30/resourceGroups/rg-${local.short_region}-grafana-logging-prod/providers/Microsoft.EventHub/namespaces/evhns-${local.short_region}-grafana-logging-prod"
      # TODO: Get from ubiq_resources module once it's available there - move to diagnostics module?
    }
  }
  diagnostics_resource_ids = merge({
    kv  = module.avm-res-keyvault-vault.resource_id
    app = local.web_app_resource_id
    },
    local.add_staging_slot ? { app_staging = local.web_app_staging_slot_ids[0] } : {},
    var.enable_sqldb_diagnostic_settings ? { sql_db = azurerm_mssql_database.main.id } : {}
  )
  diagnostics_storage_resource_ids = merge(
    var.enable_storage_blob_diagnostic_settings ? {
      main = {
        id = (nonsensitive(module.avm-res-storage-storageaccount.resource.id))
      }
    } : {}
  )
  mssql = {
    mssql_server_auditing_enabled                   = var.enable_sql_advanced_auditing
    mssql_server_microsoft_support_auditing_enabled = var.enable_sql_ms_support_auditing
    mssql_database_auditing_enabled                 = var.enable_sqldb_advanced_auditing
    auditing_storage_account_id                     = module.avm-res-storage-storageaccount.resource.id
    mssql_server_ids                                = { main = azurerm_mssql_server.main.id }
    mssql_database_ids                              = { main = azurerm_mssql_database.main.id }
    resource_metric_alerts_enabled                  = var.resource_metric_alerts_enabled
    mssql_location                                  = azurerm_mssql_server.main.location
  }
  web_app = {
    resource_ids                = { main = local.web_app_resource_id }
    response_time_alert_enabled = var.amais_response_time_alert_enabled
    server_errors_alert_enabled = var.amais_server_errors_alert_enabled
    health_check_alert_enabled  = var.amais_health_check_alert_enabled
  }
  tags       = merge(var.tags, local.common_tags)
  depends_on = [time_sleep.diagnostics_migration]
}
