resource "azurerm_monitor_metric_alert" "traffic_manager_endpoint_degraded" {
  for_each = var.traffic_manager_profiles

  name                 = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} endpoint degraded"
  resource_group_name  = provider::azurerm::parse_resource_id(each.value.resource_id)["resource_group_name"]
  description          = "Traffic Manager endpoint is degraded"
  scopes               = [each.value.resource_id]
  enabled              = true
  severity             = 2
  auto_mitigate        = true
  frequency            = "PT5M"
  window_size          = each.value.check_window
  target_resource_type = "Microsoft.Network/trafficManagerProfiles"
  tags                 = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/trafficManagerProfiles"
    metric_name      = "ProbeAgentCurrentEndpointStateByProfileResourceId"
    aggregation      = "Minimum"
    operator         = "LessThan"
    threshold        = 1
    dimension {
      name     = "EndpointName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = local.action_group_ids[each.value.endpoint_alert_action_group]
  }
}

resource "azurerm_monitor_metric_alert" "traffic_manager_profile_degraded" {
  for_each = var.traffic_manager_profiles

  name                 = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} all endpoints degraded"
  resource_group_name  = provider::azurerm::parse_resource_id(each.value.resource_id)["resource_group_name"]
  description          = "All Traffic Manager endpoints are degraded"
  scopes               = [each.value.resource_id]
  enabled              = true
  severity             = 0
  auto_mitigate        = true
  frequency            = "PT5M"
  window_size          = each.value.check_window
  target_resource_type = "Microsoft.Network/trafficManagerProfiles"
  tags                 = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/trafficManagerProfiles"
    metric_name      = "ProbeAgentCurrentEndpointStateByProfileResourceId"
    aggregation      = "Maximum"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = local.action_group_ids[each.value.all_endpoint_alert_action_group]
  }
}
