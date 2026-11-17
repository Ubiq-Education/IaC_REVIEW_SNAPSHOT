resource "azurerm_monitor_metric_alert" "uks_sql_cpu" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name                     = "${each.key} SQL CPU"
  resource_group_name      = data.azurerm_resource_group.main.name
  description              = "${each.key} SQL CPU usage is more than 90%"
  scopes                   = [azurerm_mssql_database.uks[each.key].id]
  enabled                  = true
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = "PT30M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = azurerm_mssql_server.uks.location # Take location from parent server
  tags                     = local.common_tags
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }
  action {
    action_group_id = data.azurerm_monitor_action_group.ubiq_warning.id
  }
}

resource "azurerm_monitor_metric_alert" "uks_sql_disk_space" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name                     = "${each.key} SQL disk space"
  resource_group_name      = data.azurerm_resource_group.main.name
  description              = "${each.key} SQL disk space usage is more than 80%"
  scopes                   = [azurerm_mssql_database.uks[each.key].id]
  enabled                  = true
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = "PT5M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = azurerm_mssql_server.uks.location # Take location from parent server
  tags                     = local.common_tags
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "storage_percent"
    aggregation      = "Maximum"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = data.azurerm_monitor_action_group.ubiq_warning.id
  }
}

resource "azurerm_monitor_metric_alert" "uks_sql_data_io" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name                     = "${each.key} SQL data IO"
  resource_group_name      = data.azurerm_resource_group.main.name
  description              = "${each.key} SQL data IO usage is more than 80%"
  scopes                   = [azurerm_mssql_database.uks[each.key].id]
  enabled                  = true
  severity                 = 2
  auto_mitigate            = true
  frequency                = "PT5M"
  window_size              = "PT30M"
  target_resource_type     = "Microsoft.Sql/servers/databases"
  target_resource_location = azurerm_mssql_server.uks.location # Take location from parent server
  tags                     = local.common_tags
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "physical_data_read_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = data.azurerm_monitor_action_group.ubiq_warning.id
  }
}
