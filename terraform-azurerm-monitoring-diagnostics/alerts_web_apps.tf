resource "azurerm_monitor_metric_alert" "response_time" {
  for_each = var.web_app.resource_ids

  name                = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} response time"
  resource_group_name = provider::azurerm::parse_resource_id(each.value)["resource_group_name"]
  description         = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} average response time is more than 30 seconds"
  scopes              = [provider::azurerm::normalise_resource_id(each.value)]
  enabled             = var.web_app.response_time_alert_enabled
  severity            = 2
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HttpResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 30
  }

  action {
    action_group_id = local.action_group_ids[var.web_app.response_time_alert_action_group]
  }
}

resource "azurerm_monitor_metric_alert" "server_errors" {
  for_each = var.web_app.resource_ids

  name                = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} server errors"
  resource_group_name = provider::azurerm::parse_resource_id(each.value)["resource_group_name"]
  description         = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} server errors are more than 10 in the last 5 minutes"
  scopes              = [provider::azurerm::normalise_resource_id(each.value)]
  enabled             = var.web_app.server_errors_alert_enabled
  severity            = 1
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = local.action_group_ids[var.web_app.server_errors_alert_action_group]
  }
}

resource "azurerm_monitor_metric_alert" "health_check" {
  for_each = var.web_app.resource_ids

  name                = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} health check"
  resource_group_name = provider::azurerm::parse_resource_id(each.value)["resource_group_name"]
  description         = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} health check status failed"
  scopes              = [provider::azurerm::normalise_resource_id(each.value)]
  enabled             = var.web_app.health_check_alert_enabled
  severity            = 0
  auto_mitigate       = true
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = local.action_group_ids[var.web_app.health_check_alert_action_group]
  }
}
