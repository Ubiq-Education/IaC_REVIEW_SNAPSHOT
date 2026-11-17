data "azapi_resource_list" "vnets" {
  count = var.get_vnets ? 1 : 0

  type                   = "Microsoft.Network/virtualNetworks@2025-05-01"
  parent_id              = local.shared_sub_resource_id
  response_export_values = ["*"]
}

data "azapi_resource_list" "secure_access_gw_pips" {
  count = var.get_securegw_pips ? 1 : 0

  type      = "Microsoft.Network/publicIPAddresses@2025-05-01"
  parent_id = local.shared_sub_resource_id
  query_parameters = {
    "$filter" = ["tagName eq 'secure_access_gw' and tagValue eq 'true'"]
  }
  response_export_values = {
    "values" = "value[].{name: name, id: id, location: location, ipAddress: properties.ipAddress, natGatewayId: properties.natGateway.id}"
  }
}

data "azuread_application" "pum_api_staging" {
  count = var.get_pum ? 1 : 0

  object_id = "37784a2c-6cd7-4ae5-810b-9f88b1de1744"
}

data "azuread_application" "pum_api_prod" {
  count = var.get_pum ? 1 : 0

  object_id = "ec2eb254-5193-44e9-9f78-7894c2b9168e"
}

data "azapi_resource" "eventhub_namespace_pum_staging" {
  count = var.get_pum ? 1 : 0

  type                   = "Microsoft.EventHub/namespaces@2024-01-01"
  name                   = "evgns-uks-amais-pum-staging"
  parent_id              = "${local.shared_sub_resource_id}/resourceGroups/rg-uks-amais-pum-staging"
  response_export_values = ["properties.serviceBusEndpoint"]
}

data "azapi_resource" "eventhub_namespace_pum_prod" {
  count = var.get_pum ? 1 : 0

  type                   = "Microsoft.EventHub/namespaces@2024-01-01"
  name                   = "evgns-uks-amais-pum"
  parent_id              = "${local.shared_sub_resource_id}/resourceGroups/rg-uks-amais-pum"
  response_export_values = ["properties.serviceBusEndpoint"]
}

data "http" "google_user_triggered_fetchers" {
  count = var.get_google_bot_ips ? 1 : 0

  url = "https://developers.google.com/static/crawling/ipranges/user-triggered-fetchers-google.json"
  request_headers = {
    Accept = "application/json"
  }
}
