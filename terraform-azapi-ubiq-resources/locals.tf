locals {
  shared_sub_resource_id = "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf"
  all_vnets              = var.get_vnets ? data.azapi_resource_list.vnets[0].output.value : null
  hub_vnets              = var.get_vnets ? [for vnet in data.azapi_resource_list.vnets[0].output.value : vnet if endswith(vnet.name, "-hub")] : null
  twingate_subnets = local.hub_vnets != null ? merge(
    [
      for vnet in local.hub_vnets : {
        for sub in vnet.properties.subnets : "${vnet.name}:${sub.name}" => {
          id             = sub.id
          name           = sub.name
          address_prefix = sub.properties.addressPrefix
          vnet_id        = vnet.id
        }
        if endswith(sub.name, "-twingate-ci")
      }
    ]...
  ) : {}
  terraform_subnets = local.hub_vnets != null ? merge(
    [
      for vnet in local.hub_vnets : {
        for sub in vnet.properties.subnets : "${vnet.name}:${sub.name}" => {
          id             = sub.id
          name           = sub.name
          address_prefix = sub.properties.addressPrefix
          vnet_id        = vnet.id
        }
        if endswith(sub.name, "-terraform-agents-ci")
      }
    ]...
  ) : {}
  devops_subnets = local.hub_vnets != null ? merge(
    [
      for vnet in local.hub_vnets : {
        for sub in vnet.properties.subnets : "${vnet.name}:${sub.name}" => {
          id             = sub.id
          name           = sub.name
          address_prefix = sub.properties.addressPrefix
          vnet_id        = vnet.id
        }
        if strcontains(sub.name, "-devops-agent-pool")
      }
    ]...
  ) : {}
  secure_access_gw_pips = var.get_securegw_pips ? { for pip in data.azapi_resource_list.secure_access_gw_pips[0].output.values : pip.name => {
    id                 = pip.id
    reource_group_name = provider::azapi::parse_resource_id("Microsoft.Network/publicIPAddresses", pip.id)["resource_group_name"]
    location           = pip.location
    ip_address         = pip.ipAddress
    nat_gateway_id     = pip.natGatewayId
    }
  } : {}
  pum_api = var.get_pum ? {
    staging = {
      identifier_uri = [for uri in data.azuread_application.pum_api_staging[0].identifier_uris : uri if startswith(uri, "api://")][0]
      url            = "https://func-amais-pum-api-01-staging.azurewebsites.net/api"
      eventhub_fqdn  = regex("^https://([^:/]+)", data.azapi_resource.eventhub_namespace_pum_staging[0].output.properties.serviceBusEndpoint)[0]
      eventhub_name  = "evh-amais-pum-usage-log"
      resource_id    = data.azapi_resource.eventhub_namespace_pum_staging[0].resource_id
    }
    prod = {
      identifier_uri = [for uri in data.azuread_application.pum_api_prod[0].identifier_uris : uri if startswith(uri, "api://")][0]
      url            = "https://func-amais-pum-api-01.azurewebsites.net/api"
      eventhub_fqdn  = regex("^https://([^:/]+)", data.azapi_resource.eventhub_namespace_pum_prod[0].output.properties.serviceBusEndpoint)[0]
      eventhub_name  = "evh-amais-pum-usage-log"
      resource_id    = data.azapi_resource.eventhub_namespace_pum_prod[0].resource_id
    }
  } : {}
  google_user_triggered_fetcher_ips = var.get_google_bot_ips ? toset([
    for prefix in jsondecode(data.http.google_user_triggered_fetchers[0].response_body).prefixes :
    try(prefix.ipv4Prefix, prefix.ipv6Prefix)
  ]) : []
}
