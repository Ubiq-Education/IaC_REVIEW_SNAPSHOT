module "monitoring_diagnostics" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    log_analytics = {
      enabled = true
    }
  }
  diagnostics_resource_ids = merge(
    { for k, v in module.avm-res-keyvault-vault : "keyvault-${k}" => nonsensitive(v.resource_id) }
  )
  tags = local.tags
}

module "monitoring_diagnostics_eventhub" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    log_analytics = {
      enabled = true
    }
  }
  diagnostics_resource_ids = merge(
    { for k, v in module.eventhub : "eventhub-${k}" => nonsensitive(v.azurerm_eventhub_namespace.id) }
  )
  enabled_log_categories = ["DiagnosticErrorLogs"]
  tags                   = local.tags
}
