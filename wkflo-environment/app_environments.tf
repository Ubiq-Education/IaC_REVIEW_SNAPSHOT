resource "azurerm_log_analytics_workspace" "main" {
  for_each = var.regions_enabled

  name                = "log-ai-${local.cae_names[each.key]}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = each.key
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_application_insights" "main" {
  for_each = var.regions_enabled

  name                         = "ai-${local.cae_names[each.key]}"
  resource_group_name          = azurerm_resource_group.main[each.key].name
  location                     = each.key
  workspace_id                 = azurerm_log_analytics_workspace.main[each.key].id
  application_type             = "web"
  local_authentication_enabled = true # TODO: Test if this can be disabled to force use of MI for authentication, will need to ensure the MI(?) has Monitoring Metrics Publisher role
  retention_in_days            = 30
  tags                         = local.tags
}

module "avm-res-app-managedenvironment" {
  for_each = var.regions_enabled

  source                            = "Azure/avm-res-app-managedenvironment/azurerm"
  version                           = "0.5.0"
  enable_telemetry                  = false
  name                              = local.cae_names[each.key]
  location                          = each.key
  resource_group_name               = azurerm_resource_group.main[each.key].name
  parent_id                         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.main[each.key].name}"
  log_analytics_workspace           = local.cae_regions[each.key].log_analytics_workspace
  infrastructure_resource_group     = "${azurerm_resource_group.main[each.key].name}-me-infra"
  zone_redundant                    = lookup(local.cae_regions[each.key], "zone_redundancy_enabled", false)
  dapr_ai_connection_string         = azurerm_application_insights.main[each.key].connection_string
  dapr_ai_connection_string_version = parseint(substr(sha256(azurerm_application_insights.main[each.key].connection_string), 0, 15), 16)
  public_network_access             = "Enabled"
  tags                              = local.tags
  app_logs_configuration = {
    destination = "azure-monitor"
  }
  vnet_configuration = {
    infrastructure_subnet_id = module.regional_network[each.key].subnets["wkflo-01:cae-01"].id
    internal                 = false
  }
  workload_profiles = lookup(each.value, "workload_profile",
    [{
      name                  = "Consumption"
      workload_profile_type = "Consumption"
    }]
  )
  managed_identities = merge({
    user_assigned_resource_ids = [
      module.avm-res-managedidentity-userassignedidentity-global-arcpull.resource_id,
      module.avm-res-managedidentity-userassignedidentity-cae[each.key].resource_id
    ] }, lookup(each.value, "managed_identities", {})
  )
  custom_domain_configuration = {
    dns_suffix = each.value.custom_domain_and_cert_enabled ? "${local.cae_names[each.key]}.${local.domain_suffix}" : null
    certificate_key_vault_properties = {
      identity      = each.value.custom_domain_and_cert_enabled ? module.avm-res-managedidentity-userassignedidentity-cae[each.key].resource_id : null
      key_vault_url = each.value.custom_domain_and_cert_enabled ? "${module.key_vault[each.key].uri}/secrets/${local.cae_names[each.key]}" : null
    }
  }
  peer_authentication = {
    mtls = {
      enabled = false
    }
  }
  peer_traffic_configuration = {
    encryption = {
      enabled = false
    }
  }
  dapr_components = {
    pubsub-ai = {
      name                    = "pubsub-ai"
      component_type          = "pubsub.azure.servicebus.topics"
      ignore_errors           = false
      dapr_components_version = "v1"
      scopes                  = ["amais-wkflo-ai-webapi"]
      metadata = [
        {
          name  = "azureClientId"
          value = module.avm-res-managedidentity-userassignedidentity-cae[each.key].client_id
        },
        {
          name  = "namespaceName"
          value = "sbns-${local.cae_names[each.key]}.servicebus.windows.net"
        },
        {
          name  = "consumerID"
          value = local.sbns_topic_names["pubsub-ai"]
        }
      ]
    }
    pubsub-ai-broadcast = {
      # Fan-out to EVERY AI API replica (e.g. the MAISY "chat stopped" signal on topic "wkflo-chat-stop").
      # Unlike pubsub-ai (one shared consumerID, replicas compete), consumerID is templated with {uuid}
      # so each sidecar gets its own Service Bus subscription and therefore every message.
      # Topic and subscriptions are created by Dapr entity management (CAE identity has Data Owner).
      # https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-azure-servicebus-topics/
      # https://docs.dapr.io/reference/resource-specs/component-schema/#templated-metadata-values
      name                    = "pubsub-ai-broadcast"
      component_type          = "pubsub.azure.servicebus.topics"
      ignore_errors           = true # Best-effort broadcast: a failure here must not block the AI API sidecar from starting
      dapr_components_version = "v1"
      scopes                  = ["amais-wkflo-ai-webapi"]
      metadata = [
        {
          name  = "azureClientId"
          value = module.avm-res-managedidentity-userassignedidentity-cae[each.key].client_id
        },
        {
          name  = "namespaceName"
          value = "sbns-${local.cae_names[each.key]}.servicebus.windows.net"
        },
        {
          # Subscription name per sidecar: 9 + 36 chars, within the 50-char Service Bus limit
          name  = "consumerID"
          value = "ai-bcast-{uuid}"
        },
        {
          # Removes subscriptions of replicas that are gone (Service Bus minimum is 300s)
          name  = "autoDeleteOnIdleInSec"
          value = "900"
        },
        {
          # A stop signal is only useful for a short time; don't let it pile up in orphaned subscriptions
          name  = "defaultMessageTimeToLiveInSec"
          value = "300"
        }
      ]
    }
    pubsub-worker = {
      name                    = "pubsub-worker"
      component_type          = "pubsub.azure.servicebus.topics"
      ignore_errors           = false
      dapr_components_version = "v1"
      scopes                  = ["amais-wkflo-md-webapi", "amais-wkflo-worker-webapi"]
      metadata = [
        {
          name  = "azureClientId"
          value = module.avm-res-managedidentity-userassignedidentity-cae[each.key].client_id
        },
        {
          name  = "namespaceName"
          value = "sbns-${local.cae_names[each.key]}.servicebus.windows.net"
        },
        {
          name  = "consumerID"
          value = local.sbns_topic_names["pubsub-worker"]
        }
      ]
    }
    statestore-ai = {
      # https://docs.dapr.io/developing-applications/integrations/azure/azure-authentication/howto-mi/
      # https://docs.dapr.io/reference/components-reference/supported-state-stores
      name                    = "statestore-ai"
      component_type          = "state.redis"
      ignore_errors           = false
      dapr_components_version = "v1"
      scopes                  = ["amais-wkflo-ai-webapi", "amais-wkflo-md-webapi"]
      metadata = [
        {
          name  = "redisHost",
          value = "${azurerm_managed_redis.main[each.key].hostname}:${azurerm_managed_redis.main[each.key].default_database[0].port}"
        },
        {
          name  = "useEntraID"
          value = "true"
        },
        {
          name  = "azureClientId",
          value = module.avm-res-managedidentity-userassignedidentity-cae[each.key].client_id
        },
        {
          name  = "actorStateStore",
          value = "true"
        },
        {
          name  = "enableTLS",
          value = "true"
        },
        {
          name  = "redisType",
          value = "cluster"
        }
      ]
    }
  }
  open_telemetry_configuration = try(each.value.otel_export_config.alloy_export_enabled, false) ? {
    destinations_configuration = {
      otlp_configurations = [
        {
          name     = "otlp-custom"
          endpoint = each.value.otel_export_config.alloy_grpc_endpoint
          insecure = true
        }
      ]
    }
    logs_configuration = {
      destinations = ["otlp-custom"]
    }
    metrics_configuration = {
      destinations = ["otlp-custom"]
      include_keda = true
    }
    traces_configuration = {
      destinations = ["otlp-custom"]
      include_dapr = true
    }
  } : null

  depends_on = [time_sleep.roles_acr, azurerm_managed_redis_access_policy_assignment.cae_redis]
}

resource "azapi_resource" "cae_maintenance_window" {
  for_each = var.regions_enabled

  type      = "Microsoft.App/managedEnvironments/maintenanceConfigurations@2025-07-01"
  name      = "default"
  parent_id = module.avm-res-app-managedenvironment[each.key].id
  body = {
    properties = {
      scheduledEntries = [
        {
          durationHours = try(each.value.maintenance_window.durationHours, 8)
          startHourUtc  = try(each.value.maintenance_window.startHourUtc, 23)
          weekDay       = try(each.value.maintenance_window.weekDay, "Wednesday")
        }
      ]
    }
  }
}

resource "azurerm_dns_a_record" "main" {
  for_each = var.regions_enabled

  provider            = azurerm.shared
  name                = "*.${local.cae_names[each.key]}"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl                 = 3600
  tags                = local.tags
  records             = [module.avm-res-app-managedenvironment[each.key].static_ip_address]
}

resource "azurerm_dns_txt_record" "main" {
  for_each = var.regions_enabled

  provider            = azurerm.shared
  name                = "asuid.${local.cae_names[each.key]}"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl                 = 3600
  tags                = local.tags

  record {
    # Mark as nonsensitive to as it is public information and useful to see in outputs/logs
    value = nonsensitive(module.avm-res-app-managedenvironment[each.key].custom_domain_verification_id)
  }
}

resource "time_sleep" "dns_propagation" {
  create_duration = "300s"

  depends_on = [azurerm_dns_a_record.main, azurerm_dns_txt_record.main]
}

## This certificate is the BYO cert for use by the container apps not the environment itself
resource "azurerm_container_app_environment_certificate" "main" {
  for_each = { for region, config in var.regions_enabled : region => config if config.add_cae_cert_to_byo_cert_list }

  name                         = replace(replace("${local.cae_names[each.key]}.${local.domain_suffix}", ".", "-"), "_", "-")
  container_app_environment_id = module.avm-res-app-managedenvironment[each.key].id
  tags                         = local.tags

  certificate_key_vault {
    identity            = module.avm-res-managedidentity-userassignedidentity-cae[each.key].resource_id
    key_vault_secret_id = "${module.key_vault[each.key].uri}/secrets/${local.cae_names[each.key]}"
  }

  depends_on = [time_sleep.dns_propagation]
}
