resource "azurerm_monitor_metric_alert" "ca_replica_count" {
  for_each = { for k, v in var.container_apps : k => v if v.replica_count_alert_enabled }

  name                 = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} revision count limit reached"
  resource_group_name  = provider::azurerm::parse_resource_id(each.value.resource_id)["resource_group_name"]
  description          = "Container App revision count limit reached${each.value.replica_count_threshold > 2 ? "" : " - DISABLED DUE TO LOW THRESHOLD"}"
  scopes               = [each.value.resource_id]
  enabled              = each.value.replica_count_threshold > 2 ? true : false
  severity             = 2
  auto_mitigate        = true
  frequency            = "PT5M"
  window_size          = "PT1H"
  target_resource_type = "Microsoft.App/containerApps"
  tags                 = var.tags

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "Replicas"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = each.value.replica_count_threshold >= 1 ? each.value.replica_count_threshold : 1
  }

  action {
    action_group_id = local.action_group_ids[each.value.replica_count_action_group]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "cae_readiness_probe" {
  # Should be created once per Container App across all regions, as the query is scoped to the Log Analytics workspace.
  # Assuming all CAE's connected to the same workspace.
  # IMPORTANT: The calling module is responsible for ensuring this is the case.
  for_each = { for k, v in var.container_apps : k => v if v.readiness_probe_failure_alert_enabled }

  name                    = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} readiness probe failed"
  resource_group_name     = provider::azurerm::parse_resource_id(each.value.resource_id)["resource_group_name"]
  location                = each.value.law_location
  description             = "Container App readiness probe failed"
  scopes                  = [each.value.law_resource_id]
  enabled                 = true
  severity                = 2
  auto_mitigation_enabled = true
  evaluation_frequency    = "PT5M"
  window_duration         = "PT5M"
  target_resource_types   = ["Microsoft.OperationalInsights/workspaces"]
  tags                    = var.tags

  criteria {
    operator                = "GreaterThan"
    query                   = <<-EOT
    ContainerAppSystemLogs
    | where ContainerAppName =~ "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]}"
    | where Reason =~ "ProbeFailed"
    | where Log matches regex "(?i)Readiness"
    | summarize Count = count() by Location, bin(TimeGenerated, 1m)
    EOT
    threshold               = each.value.readiness_probe_failure_threshold
    time_aggregation_method = "Maximum"
    metric_measure_column   = "Count"
    dimension {
      name     = "Location"
      operator = "Include"
      values   = ["*"]
    }
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [local.action_group_ids[each.value.readiness_probe_failure_action_group]]
  }
}
