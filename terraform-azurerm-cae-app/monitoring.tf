module "monitoring_diagnostics" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    event_hub = {
      enabled               = true
      eventhub_namespace_id = "/subscriptions/da462007-44f7-4547-ab47-679054904e30/resourceGroups/rg-${local.short_region}-grafana-logging-prod/providers/Microsoft.EventHub/namespaces/evhns-${local.short_region}-grafana-logging-prod"
    }
  }
  container_apps = {
    main = {
      resource_id                           = module.container_app.container_app.id
      law_resource_id                       = data.azurerm_log_analytics_workspace.cae.id
      law_location                          = data.azurerm_log_analytics_workspace.cae.location
      replica_count_alert_enabled           = var.replica_count_alert_enabled
      readiness_probe_failure_alert_enabled = var.readiness_probe_failure_alert_enabled
      replica_count_threshold               = floor(var.template.max_replicas * 0.95)
    }
  }
  tags = var.tags
}
