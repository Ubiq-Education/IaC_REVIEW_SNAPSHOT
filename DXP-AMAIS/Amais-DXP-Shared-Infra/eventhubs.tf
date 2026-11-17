locals {
  dxp_ingress_event_hubs = {
    analytics-ingress = {
      status                  = "Active"
      partition_count         = 1
      retention_time_in_hours = 168
      consumer_groups         = ["analytics-service"]
    }
    analytics-staging-ingress = {
      status                  = "Active"
      partition_count         = 1
      retention_time_in_hours = 48
      consumer_groups         = ["analytics-service"]
    }
    bulk-interactions-development-ingress = {
      status                  = "Active"
      partition_count         = 2
      retention_time_in_hours = 168
      consumer_groups         = ["bulk-interations-service"]
    }
    bulk-interactions-ingress = {
      status                  = "Active"
      partition_count         = 1
      retention_time_in_hours = 168
      consumer_groups         = ["bulk-interations-service"]
    }
    bulk-interactions-staging-ingress = {
      status                  = "Active"
      partition_count         = 1
      retention_time_in_hours = 48
      consumer_groups         = ["bulk-interations-service"]
    }
    interactions-development-ingress = {
      status                  = "Active"
      partition_count         = 2
      retention_time_in_hours = 168
      consumer_groups         = ["interaction-service"]
    }
    interactions-ingress = {
      status                  = "Active"
      partition_count         = 2
      retention_time_in_hours = 168
      consumer_groups         = ["interaction-service"]
    }
    interactions-staging-ingress = {
      status                  = "Active"
      partition_count         = 2
      retention_time_in_hours = 48
      consumer_groups         = ["interaction-service", "victor-local"]
    }
  }
  indexed_consumer_groups = {
    for cg in flatten([
      for event_hub, details in local.dxp_ingress_event_hubs : [
        for consumer_group in details.consumer_groups : {
          consumer_group = consumer_group
          event_hub      = event_hub
        }
      ]
    ]) : "${cg.event_hub}-${cg.consumer_group}" => cg
  }
}

resource "azurerm_eventhub_namespace" "dxp_ingress" {
  name                          = "amais-dxp-ingress"
  location                      = "uksouth"
  resource_group_name           = lower(local.resource_group_name)
  sku                           = "Standard"
  capacity                      = 1
  auto_inflate_enabled          = false
  local_authentication_enabled  = true
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"
  tags                          = local.common_tags

  dynamic "network_rulesets" {
    for_each = [local.network_rulesets]
    content {
      default_action                 = "Deny"
      trusted_service_access_enabled = true
      public_network_access_enabled  = true
      dynamic "ip_rule" {
        for_each = network_rulesets.value.secure_access_gw_ip_addresses
        content {
          ip_mask = ip_rule.value
          action  = "Allow"
        }
      }
      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.vnet_integration_subnet_ids
        content {
          subnet_id                                       = virtual_network_rule.value
          ignore_missing_virtual_network_service_endpoint = true
        }
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "dxp_ingress" {
  name                       = local.diag_settings_name
  target_resource_id         = azurerm_eventhub_namespace.dxp_ingress.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "audit"
  }
}

resource "azurerm_eventhub" "dxp_ingress" {
  for_each = local.dxp_ingress_event_hubs

  name            = each.key
  namespace_id    = azurerm_eventhub_namespace.dxp_ingress.id
  partition_count = each.value.partition_count

  retention_description {
    cleanup_policy                    = try(each.value.cleanup_policy, "Delete")
    retention_time_in_hours           = try(each.value.retention_time_in_hours, null)
    tombstone_retention_time_in_hours = try(each.value.tombstone_retention_time_in_hours, null)
  }
}

resource "azurerm_eventhub_consumer_group" "dxp_ingress" {
  for_each = local.indexed_consumer_groups

  name                = each.value.consumer_group
  namespace_name      = azurerm_eventhub_namespace.dxp_ingress.name
  eventhub_name       = each.value.event_hub
  resource_group_name = lower(local.resource_group_name)
}
