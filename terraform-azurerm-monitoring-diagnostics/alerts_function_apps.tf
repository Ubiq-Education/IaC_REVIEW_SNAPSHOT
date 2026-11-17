resource "azurerm_monitor_metric_alert" "func_app_inactivity" {
  for_each = { for k, v in var.function_apps : k => v if v.max_inactivity_alert_enabled }

  name                     = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} inactivity"
  resource_group_name      = provider::azurerm::parse_resource_id(each.value.resource_id)["resource_group_name"]
  description              = "Function app has not run within the expected time window"
  scopes                   = [each.value.resource_id]
  enabled                  = true
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = each.value.max_inactivity_window
  target_resource_type     = "Microsoft.Web/sites"
  target_resource_location = each.value.location
  tags                     = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AlwaysReadyFunctionExecutionCount"
    aggregation      = "Count"
    operator         = "LessThan"
    threshold        = 1
  }

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "OnDemandFunctionExecutionCount"
    aggregation      = "Count"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = local.action_group_ids[each.value.inactivity_alert_action_group]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "func_app_failures" {
  for_each = { for k, v in var.function_apps : k => v if v.max_failures_alert_enabled }

  name                    = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} Failures"
  resource_group_name     = provider::azurerm::parse_resource_id(each.value.insights_resource_id)["resource_group_name"]
  location                = each.value.location
  description             = "Invocation failure threshold exceeded"
  scopes                  = [each.value.insights_resource_id]
  enabled                 = true
  severity                = "2"
  auto_mitigation_enabled = true
  evaluation_frequency    = "PT5M"
  window_duration         = each.value.max_failures_window
  target_resource_types   = ["Microsoft.Insights/components"]
  tags                    = var.tags

  criteria {
    operator                = "GreaterThanOrEqual"
    query                   = <<-EOT
    requests
    | where success !~ "True"
    EOT
    threshold               = each.value.max_failures_threshold
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [local.action_group_ids[each.value.failure_alert_action_group]]
  }

}
