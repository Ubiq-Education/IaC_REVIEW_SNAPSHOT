resource "azurerm_monitor_metric_alert" "nat_gw_snat" {
  for_each = var.nat_gateways

  name                = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} SNAT port usage"
  resource_group_name = provider::azurerm::parse_resource_id(each.value.resource_id)["resource_group_name"]
  description         = "${provider::azurerm::parse_resource_id(each.value.resource_id)["resource_name"]} SNAT port usage is near exhaustion"
  scopes              = [provider::azurerm::normalise_resource_id(each.value.resource_id)]
  enabled             = each.value.snat_alert_enabled
  severity            = 2
  auto_mitigate       = true
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/natGateways"
    metric_name      = "TotalConnectionCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    # Alert on 95% of allocated SNAT ports being used
    threshold = floor((each.value.allocated_ips * 64512) * 0.95)
  }

  action {
    action_group_id = local.action_group_ids[each.value.alerts_action_group]
  }
}
