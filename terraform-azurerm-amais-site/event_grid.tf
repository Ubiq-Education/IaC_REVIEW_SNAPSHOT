resource "azurerm_eventgrid_system_topic" "main_app" {
  name                = "egst-${local.app_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  source_resource_id  = local.web_app_resource_id
  topic_type          = "Microsoft.Web.Sites"
  tags                = merge(var.tags, local.common_tags)
}

resource "azurerm_eventgrid_system_topic_event_subscription" "slot_swap" {
  name                  = "evgs-${local.app_name}-slot-swap"
  system_topic          = azurerm_eventgrid_system_topic.main_app.name
  resource_group_name   = azurerm_resource_group.main.name
  event_delivery_schema = "EventGridSchema"
  included_event_types = [
    "Microsoft.Web.SlotSwapCompleted",
    "Microsoft.Web.SlotSwapFailed"
  ]

  azure_function_endpoint {
    function_id                       = "/subscriptions/${local.shared_sub_id}/resourceGroups/rg-uks-ubiq-automation/providers/Microsoft.Web/sites/func-uks-ubiq-automation/functions/app-swap-cms-version-update"
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  retry_policy {
    max_delivery_attempts = 3
    event_time_to_live    = "60"
  }
}
