module "eventhub" {
  for_each = local.regions

  source                                = "./modules/eventhubs"
  az_long_region                        = azurerm_resource_group.main[each.key].location
  resource_group_name                   = azurerm_resource_group.main[each.key].name
  eventhub_namespace_name               = "evhns-${module.short-region-lookup[each.key].short_region}-${local.deployment_name}"
  eventhub_namespace_capacity           = 1
  eventhub_namespace_allowed_subnet_ids = [data.azurerm_subnet.amais_central_functions_05[each.key].id]
  event_hubs = {
    "logevents" = {
      status                  = "Active"
      partition_count         = 4
      retention_time_in_hours = 168
    }
  }
  tags                       = local.tags
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id
}
