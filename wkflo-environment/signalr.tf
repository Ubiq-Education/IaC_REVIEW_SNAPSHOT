resource "azurerm_signalr_service" "main" {
  for_each = var.regions_enabled

  name                                     = "sigr-${local.cae_names[each.key]}"
  location                                 = azurerm_resource_group.main[each.key].location
  resource_group_name                      = azurerm_resource_group.main[each.key].name
  local_auth_enabled                       = false
  serverless_connection_timeout_in_seconds = coalesce(try(each.value.signalr_config.serverless_connection_timeout_in_seconds, null), 30)
  connectivity_logs_enabled                = true
  http_request_logs_enabled                = true
  messaging_logs_enabled                   = false
  tags                                     = local.tags

  sku {
    name     = local.sigr_sku_name[each.key]
    capacity = coalesce(try(each.value.signalr_config.sku_capacity, null), 1)
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-sigr[each.key].resource_id]
  }
}

resource "azurerm_dns_cname_record" "signalr_custom_domain" {
  for_each = { for region, config in var.regions_enabled : region => config if local.sigr_custom_domain_and_cert_enabled[region] }

  provider            = azurerm.shared
  name                = trimsuffix(each.value.signalr_config.custom_domain_fqdn, ".${local.domain_suffix}")
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl                 = lookup(each.value, "ttl", 300)
  record              = azurerm_signalr_service.main[each.key].hostname
  tags                = local.tags
}

resource "azurerm_signalr_service_custom_certificate" "main" {
  for_each = { for region, config in var.regions_enabled : region => config if local.sigr_custom_domain_and_cert_enabled[region] }

  name                  = each.value.signalr_config.key_vault_certificate_name
  signalr_service_id    = azurerm_signalr_service.main[each.key].id
  custom_certificate_id = data.azurerm_key_vault_certificate.sigr[each.key].id
}

resource "azurerm_signalr_service_custom_domain" "main" {
  for_each = { for region, config in var.regions_enabled : region => config if local.sigr_custom_domain_and_cert_enabled[region] }

  name                          = replace(each.value.signalr_config.custom_domain_fqdn, ".", "-")
  signalr_service_id            = azurerm_signalr_service.main[each.key].id
  domain_name                   = each.value.signalr_config.custom_domain_fqdn
  signalr_custom_certificate_id = azurerm_signalr_service_custom_certificate.main[each.key].id
}

resource "azurerm_role_assignment" "developer_signalr_rest_api_owner" {
  for_each = { for region, config in var.regions_enabled : region => config if local.is_staging }

  scope                = azurerm_signalr_service.main[each.key].id
  role_definition_name = "SignalR REST API Owner"
  principal_id         = data.azuread_group.devs.object_id
}

resource "azurerm_role_assignment" "developer_signalr_app_server" {
  for_each = { for region, config in var.regions_enabled : region => config if local.is_staging }

  scope                = azurerm_signalr_service.main[each.key].id
  role_definition_name = "SignalR App Server"
  principal_id         = data.azuread_group.devs.object_id
}
