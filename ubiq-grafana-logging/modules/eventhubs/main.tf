resource "azurerm_eventhub_namespace" "main" {
  name                          = startswith(var.eventhub_namespace_name, "evhns-") ? var.eventhub_namespace_name : "evhns-${var.eventhub_namespace_name}"
  location                      = var.az_long_region
  resource_group_name           = var.resource_group_name
  sku                           = var.eventhub_namespace_sku
  capacity                      = var.eventhub_namespace_capacity
  auto_inflate_enabled          = false
  local_authentication_enabled  = true # Required for Azure Diagnostic Settings to be able to send to the Event Hub
  public_network_access_enabled = true
  minimum_tls_version           = var.eventhub_namespace_minimum_tls_version
  tags                          = var.tags
  network_rulesets {
    default_action                 = "Deny"
    public_network_access_enabled  = true
    trusted_service_access_enabled = true

    # Dynamic blocks in this scenario do not work for unknown reasons,
    # See https://github.com/hashicorp/terraform-provider-azurerm/issues/10382
    # but as `virtual_network_rule` is a list, we can create elements in the list with a for loop
    virtual_network_rule = [
      for subnet_id in var.eventhub_namespace_allowed_subnet_ids :
      {
        ignore_missing_virtual_network_service_endpoint = false
        subnet_id                                       = subnet_id
      }
    ]
  }
}

# Required for Azure Diagnostic Settings to be able to send to the Event Hub
resource "azurerm_eventhub_namespace_authorization_rule" "send" {
  name                = "SendEvents"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_eventhub" "main" {
  for_each = var.event_hubs

  name            = startswith(each.key, "evh-") ? each.key : "evh-${each.key}"
  namespace_id    = azurerm_eventhub_namespace.main.id
  partition_count = each.value.partition_count

  retention_description {
    cleanup_policy                    = try(each.value.cleanup_policy, "Delete")
    retention_time_in_hours           = try(each.value.retention_time_in_hours, null)
    tombstone_retention_time_in_hours = try(each.value.tombstone_retention_time_in_hours, null)
  }
}

resource "azurerm_eventhub_consumer_group" "main" {
  for_each = local.indexed_consumer_groups

  name                = each.value.consumer_group
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.main[each.value.event_hub].name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "eventhub_data_sender" {
  for_each = local.eventhub_data_sender_roles

  scope                = azurerm_eventhub.main[each.value.event_hub].id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "eventhub_data_receiver" {
  for_each = local.eventhub_data_receiver_roles

  scope                = azurerm_eventhub.main[each.value.event_hub].id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = each.value.principal_id
}
