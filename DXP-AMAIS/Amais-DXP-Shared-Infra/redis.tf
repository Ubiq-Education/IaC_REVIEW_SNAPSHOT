resource "azurerm_key_vault_key" "redis" {
  name            = "amr-uks-dxp-key"
  key_vault_id    = module.dxp_keyvault_uk.resource_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = local.common_tags

  rotation_policy {
    expire_after         = "P1Y"
    notify_before_expiry = "P28D"
    automatic {
      time_before_expiry = "P30D"
    }
  }

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "time_sleep" "redis_keys" {
  create_duration = "30s"

  triggers = {
    key = azurerm_key_vault_key.redis.id
  }
}

# Wait for initial rotation and get new ids for output
data "azurerm_key_vault_key" "redis" {
  name         = azurerm_key_vault_key.redis.name
  key_vault_id = module.dxp_keyvault_uk.resource_id

  depends_on = [time_sleep.redis_keys]
}

resource "azurerm_role_assignment" "kv_redis_crypto_service_encryption_user" {

  scope                = module.dxp_keyvault_uk.resource_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-redis.principal_id

  depends_on = [time_sleep.identities]
}

resource "time_sleep" "azurerm_role_assignments" {
  create_duration = "60s"

  triggers = {
    redis_id = azurerm_role_assignment.kv_redis_crypto_service_encryption_user.id
  }
}

resource "azurerm_managed_redis" "main" {
  name                      = "amr-uks-dxp"
  location                  = "uksouth"
  resource_group_name       = lower(local.resource_group_name)
  sku_name                  = "Balanced_B3"
  high_availability_enabled = true
  public_network_access     = "Enabled"
  tags                      = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-redis.resource_id]
  }

  customer_managed_key {
    key_vault_key_id          = data.azurerm_key_vault_key.redis.id
    user_assigned_identity_id = module.avm-res-managedidentity-userassignedidentity-redis.resource_id
  }

  default_database {
    access_keys_authentication_enabled = false
    eviction_policy                    = "AllKeysLRU"
  }

  depends_on = [time_sleep.azurerm_role_assignments]

  lifecycle {
    ignore_changes = [customer_managed_key[0].key_vault_key_id]
  }
}

resource "azapi_update_resource" "redis_maintenance_window" {
  type        = "Microsoft.Cache/redisEnterprise@2026-02-01-preview"
  resource_id = azurerm_managed_redis.main.id

  body = {
    properties = {
      maintenanceConfiguration = {
        maintenanceWindows = [
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Monday"
            }
            startHourUtc = 7
            type         = "Weekly"
          },
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Tuesday"
            }
            startHourUtc = 7
            type         = "Weekly"
          },
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Wednesday"
            }
            startHourUtc = 7
            type         = "Weekly"
          },
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Thursday"
            }
            startHourUtc = 7
            type         = "Weekly"
          },
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Friday"
            }
            startHourUtc = 7
            type         = "Weekly"
          },
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Saturday"
            }
            startHourUtc = 7
            type         = "Weekly"
          },
          {
            duration = "PT4H"
            schedule = {
              dayOfWeek = "Sunday"
            }
            startHourUtc = 7
            type         = "Weekly"
          }
        ]
      }
    }
  }

  response_export_values = ["properties.maintenanceConfiguration.maintenanceWindows"]
}

resource "azurerm_managed_redis_access_policy_assignment" "dxp_developers" {
  for_each = toset(data.azuread_group.dxp_developers.members)

  managed_redis_id = azurerm_managed_redis.main.id
  object_id        = each.key
}

module "monitoring_diagnostics_redis" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.2"
  diagnostics_destinations = {
    log_analytics = {
      enabled = true
    }
  }
  diagnostics_resource_ids = {
    redis = azurerm_managed_redis.main.default_database[0].id
  }
  tags = local.common_tags
}
