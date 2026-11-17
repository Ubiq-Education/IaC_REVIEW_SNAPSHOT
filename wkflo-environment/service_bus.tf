module "avm-res-servicebus-namespace" {
  for_each = var.regions_enabled

  source              = "Azure/avm-res-servicebus-namespace/azurerm"
  version             = "~>0.4"
  enable_telemetry    = false
  name                = "sbns-${local.cae_names[each.key]}"
  location            = azurerm_resource_group.main[each.key].location
  resource_group_name = azurerm_resource_group.main[each.key].name
  sku                 = "Standard"
  local_auth_enabled  = false
  tags                = local.tags

  # Identity and key vault role assignment for future CMK encryption if upgraded to premium SKU
  managed_identities = {
    system_assigned            = false
    user_assigned_resource_ids = [module.avm-res-managedidentity-userassignedidentity-sbns[each.key].resource_id]
  }

  network_rule_config = {
    "cidr_or_ip_rules" : []
    "default_action" : "Allow"
    "network_rules" : [] # Requires premium SKU
    "trusted_services_allowed" : true
  }

  role_assignments = merge(
    {
      cae_umi_data_owner = {
        role_definition_id_or_name = "Azure Service Bus Data Owner"
        principal_id               = module.avm-res-managedidentity-userassignedidentity-cae[each.key].principal_id
      }
    },
    local.is_staging ? {
      developer_umi_data_owner = {
        role_definition_id_or_name = "Azure Service Bus Data Owner"
        principal_id               = data.azuread_group.devs.object_id
      }
    } : {}
  )

  topics = {
    for topic_key, topic_name in local.sbns_topic_names : topic_key => {
      name                = topic_name
      enable_partitioning = true
      support_ordering    = true
    }
  }
}
