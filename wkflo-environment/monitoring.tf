module "monitoring_diagnostics_main" {
  for_each = var.regions_enabled

  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    event_hub = {
      enabled               = true
      eventhub_namespace_id = "/subscriptions/da462007-44f7-4547-ab47-679054904e30/resourceGroups/rg-${module.short-region-lookup[each.key].short_region}-grafana-logging-prod/providers/Microsoft.EventHub/namespaces/evhns-${module.short-region-lookup[each.key].short_region}-grafana-logging-prod"
      # TODO: Get from ubiq_resources module once it's available there - move to diagnostics module?
    }
  }
  diagnostics_resource_ids = {
    signalr = azurerm_signalr_service.main[each.key].id
    sbns    = module.avm-res-servicebus-namespace[each.key].resource_id
    redis   = azurerm_managed_redis.main[each.key].default_database[0].id
    pgsql   = azurerm_postgresql_flexible_server.main[each.key].id
  }
  diagnostics_storage_resource_ids = {
    netflowlogs = {
      id = nonsensitive(module.avm-res-storage-storageaccount-netflowlogs[each.key].resource.id)
    }
    sql_auditlogs = {
      id = nonsensitive(module.avm-res-storage-storageaccount-sql-auditlogs[each.key].resource.id)
    }
    cae_storage = {
      id = nonsensitive(module.avm-res-storage-storageaccount[each.key].resource.id)
    }
  }
  tags = local.tags
}

# Log container events to local LAW for Azure Alerts
module "monitoring_diagnostics_cae" {
  for_each = var.regions_enabled

  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    log_analytics = {
      enabled      = true
      workspace_id = azurerm_log_analytics_workspace.main[each.key].id
    }
  }
  diagnostics_resource_ids = {
    cae = module.avm-res-app-managedenvironment[each.key].id
  }
  tags = local.tags
}
