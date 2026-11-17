resource "azurerm_managed_redis" "main" {
  for_each = var.regions_enabled

  name                      = "amr-${local.cae_names[each.key]}"
  location                  = azurerm_resource_group.main[each.key].location
  resource_group_name       = azurerm_resource_group.main[each.key].name
  sku_name                  = coalesce(try(each.value.redis_config.sku_name, null), "Balanced_B0")
  high_availability_enabled = true
  public_network_access     = "Enabled"
  tags                      = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-redis[each.key].resource_id]
  }

  customer_managed_key {
    key_vault_key_id          = module.key_vault[each.key].keys["redis_cmk"].id
    user_assigned_identity_id = module.avm-res-managedidentity-userassignedidentity-redis[each.key].resource_id
  }

  default_database {
    access_keys_authentication_enabled = false
    eviction_policy                    = "VolatileLRU"
  }

  lifecycle {
    ignore_changes = [customer_managed_key[0].key_vault_key_id]
  }
}

resource "azurerm_managed_redis_access_policy_assignment" "cae_redis" {
  for_each = var.regions_enabled

  managed_redis_id = azurerm_managed_redis.main[each.key].id
  object_id        = module.avm-res-managedidentity-userassignedidentity-cae[each.key].principal_id
}

resource "azurerm_managed_redis_access_policy_assignment" "developer_redis" {
  for_each = local.is_staging ? local.regions_enabled_developer_map : {}

  managed_redis_id = azurerm_managed_redis.main[each.value.region].id
  object_id        = each.value.member_id
}
