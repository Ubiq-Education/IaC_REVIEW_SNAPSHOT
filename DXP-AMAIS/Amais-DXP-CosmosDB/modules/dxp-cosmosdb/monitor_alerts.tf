resource "azurerm_monitor_metric_alert" "cosmosdb_data_usage" {
  name                     = "${local.cosmosdb_name} data usage"
  resource_group_name      = var.resource_group_name
  description              = "${local.cosmosdb_name} data usage is more than ${var.cosmosdb_data_usage_alert_threshold_bytes} bytes"
  scopes                   = [azurerm_cosmosdb_account.main.id]
  enabled                  = true
  severity                 = 3
  auto_mitigate            = true
  frequency                = "PT1H"
  window_size              = "PT1H"
  target_resource_type     = "Microsoft.DocumentDB/databaseAccounts"
  target_resource_location = azurerm_cosmosdb_account.main.location # Take location from parent server
  tags                     = var.tags
  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "DataUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cosmosdb_data_usage_alert_threshold_bytes
  }
  action {
    action_group_id = data.azurerm_monitor_action_group.ubiq_warning.id
  }
}
