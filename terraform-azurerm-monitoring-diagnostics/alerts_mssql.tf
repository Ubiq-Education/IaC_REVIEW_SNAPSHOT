resource "azurerm_monitor_metric_alert" "sql_cpu" {
  for_each = var.mssql.mssql_database_ids

  name                     = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} SQL CPU"
  resource_group_name      = provider::azurerm::parse_resource_id(each.value)["resource_group_name"]
  description              = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} SQL CPU usage is more than 90%"
  scopes                   = [provider::azurerm::normalise_resource_id(each.value)]
  enabled                  = var.mssql.resource_metric_alerts_enabled
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = "PT30M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = var.mssql.mssql_location
  tags                     = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = local.action_group_ids[var.mssql.alerts_action_group]
  }
}

resource "azurerm_monitor_metric_alert" "sql_disk_space" {
  for_each = var.mssql.mssql_database_ids

  name                     = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} SQL disk space"
  resource_group_name      = provider::azurerm::parse_resource_id(each.value)["resource_group_name"]
  description              = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} SQL disk space usage is more than 80%"
  scopes                   = [provider::azurerm::normalise_resource_id(each.value)]
  enabled                  = var.mssql.resource_metric_alerts_enabled
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = "PT5M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = var.mssql.mssql_location
  tags                     = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = local.action_group_ids[var.mssql.alerts_action_group]
  }
}

resource "azurerm_monitor_metric_alert" "sql_data_io" {
  for_each = var.mssql.mssql_database_ids

  name                     = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} SQL data IO"
  resource_group_name      = provider::azurerm::parse_resource_id(each.value)["resource_group_name"]
  description              = "${provider::azurerm::parse_resource_id(each.value)["resource_name"]} SQL data IO usage is more than 80%"
  scopes                   = [provider::azurerm::normalise_resource_id(each.value)]
  enabled                  = var.mssql.resource_metric_alerts_enabled
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = "PT30M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = var.mssql.mssql_location
  tags                     = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "physical_data_read_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = local.action_group_ids[var.mssql.alerts_action_group]
  }
}

