resource "azurerm_postgresql_flexible_server" "main" {
  for_each = var.regions_enabled

  name                  = "pgsql-${local.cae_names[each.key]}"
  location              = azurerm_resource_group.main[each.key].location
  resource_group_name   = azurerm_resource_group.main[each.key].name
  sku_name              = local.postgresql_sku_name[each.key]
  backup_retention_days = "35"
  storage_mb            = coalesce(try(each.value.postgresql_config.storage_mb, null), 32768)
  storage_tier          = coalesce(try(each.value.postgresql_config.storage_tier, null), "P4")
  version               = coalesce(try(each.value.postgresql_config.version, null), "17")
  tags                  = merge(local.tags, local.data_tags.confidential)

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.avm-res-managedidentity-userassignedidentity-pgsql[each.key].resource_id
    ]
  }

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  customer_managed_key {
    key_vault_key_id                  = module.key_vault[each.key].keys["pgsql_cmk"].versionless_id
    primary_user_assigned_identity_id = module.avm-res-managedidentity-userassignedidentity-pgsql[each.key].resource_id
  }

  # Possible future use
  # cluster {
  #   size                  = coalesce(try(each.value.postgresql_config.cluster_size, null), 1)
  # }

  dynamic "high_availability" {
    for_each = startswith(local.postgresql_sku_name[each.key], "B_") ? [] : [1]

    content {
      mode = "ZoneRedundant"
    }
  }

  maintenance_window {
    day_of_week  = coalesce(try(each.value.postgresql_config.maintenance_window.day_of_week, null), 3)
    start_hour   = coalesce(try(each.value.postgresql_config.maintenance_window.start_hour, null), 0)
    start_minute = coalesce(try(each.value.postgresql_config.maintenance_window.start_minute, null), 0)
  }

  lifecycle {
    ignore_changes = [zone, high_availability[0].standby_availability_zone]
  }
}

resource "azurerm_management_lock" "pgsql" {
  for_each = var.regions_enabled

  name       = "CanNotDelete"
  scope      = azurerm_postgresql_flexible_server.main[each.key].id
  lock_level = "CanNotDelete"
  notes      = local.lock_note
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_ips" {
  for_each = var.regions_enabled

  name             = "AllowAllAzureServicesAndResourcesWithinAzureIps"
  server_id        = azurerm_postgresql_flexible_server.main[each.key].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "twingate" {
  for_each = local.region_secure_access_gw_pips_map

  name             = "Allow-${each.value.name}"
  server_id        = azurerm_postgresql_flexible_server.main[split("-", each.key)[0]].id
  start_ip_address = each.value.ip_address
  end_ip_address   = each.value.ip_address
}

resource "azurerm_postgresql_flexible_server_configuration" "main" {
  for_each = var.regions_enabled

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main[each.key].id
  value     = "AZURE_AI,VECTOR"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "developer" {
  for_each = { for region, config in var.regions_enabled : region => config if local.is_staging }

  server_name         = azurerm_postgresql_flexible_server.main[each.key].name
  resource_group_name = azurerm_resource_group.main[each.key].name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_group.devs.object_id
  principal_name      = data.azuread_group.devs.display_name
  principal_type      = "Group"
}
