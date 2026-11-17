resource "azurerm_monitor_diagnostic_setting" "main" {
  for_each = local.resultant_resource_id_map

  name               = var.diagnostics_settings_name
  target_resource_id = each.value
  log_analytics_workspace_id = (
    try(var.diagnostics_destinations.log_analytics.enabled, false) ?
    provider::azurerm::normalise_resource_id(var.diagnostics_destinations.log_analytics.workspace_id) :
    null
  )
  eventhub_name = (
    try(var.diagnostics_destinations.event_hub.enabled, false) ?
    var.diagnostics_destinations.event_hub.eventhub_name :
    null
  )
  eventhub_authorization_rule_id = (
    try(var.diagnostics_destinations.event_hub.enabled, false) ?
    provider::azurerm::normalise_resource_id("${var.diagnostics_destinations.event_hub.eventhub_namespace_id}/authorizationRules/${var.diagnostics_destinations.event_hub.shared_access_policy_name}") :
    null
  )
  storage_account_id = (
    try(var.diagnostics_destinations.storage_account.enabled, false) ?
    provider::azurerm::normalise_resource_id(var.diagnostics_destinations.storage_account.storage_account_id) :
    null
  )

  dynamic "enabled_log" {
    for_each = toset(var.enabled_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = toset(local.resultant_log_category_groups)

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.enabled_metrics)

    content {
      category = enabled_metric.value
    }
  }
}
