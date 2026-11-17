module "short_region_lookup" {
  for_each = toset(local.dxp_regions)

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

module "avm-res-managedidentity-userassignedidentity-cdb" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3.3"
  enable_telemetry    = false
  name                = "id-${local.cosmosdb_name}"
  resource_group_name = var.resource_group_name
  location            = var.az_long_region
  tags                = var.tags

  lock = {
    name = "CanNotDelete"
    kind = "CanNotDelete"
  }
}

resource "azurerm_key_vault_key" "main_cdb" {
  name            = "${local.cosmosdb_name}-key"
  key_vault_id    = data.azurerm_key_vault.main.id
  key_type        = "RSA"
  key_size        = 4096
  key_opts        = ["wrapKey", "unwrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"

  rotation_policy {
    expire_after         = "P1Y"
    notify_before_expiry = "P58D"
    automatic {
      time_before_expiry = "P60D"
    }
  }

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_key_vault_key" "main_cdb_new" {
  name            = "${local.cosmosdb_name}-2048-key"
  key_vault_id    = data.azurerm_key_vault.main.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["wrapKey", "unwrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"

  rotation_policy {
    expire_after         = "P1Y"
    notify_before_expiry = "P58D"
    automatic {
      time_before_expiry = "P60D"
    }
  }

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_role_assignment" "crypto_service_encryption_user_cdb" {
  principal_id         = module.avm-res-managedidentity-userassignedidentity-cdb.principal_id
  scope                = data.azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "time_sleep" "kv_rbac" {
  create_duration = "90s"

  depends_on = [azurerm_role_assignment.crypto_service_encryption_user_cdb]
}

resource "azurerm_cosmosdb_account" "main" {
  name                               = local.cosmosdb_name
  resource_group_name                = var.resource_group_name
  location                           = var.az_long_region
  offer_type                         = "Standard"
  kind                               = "GlobalDocumentDB"
  access_key_metadata_writes_enabled = false
  automatic_failover_enabled         = true
  default_identity_type              = "UserAssignedIdentity=${module.avm-res-managedidentity-userassignedidentity-cdb.resource_id}"
  is_virtual_network_filter_enabled  = true
  key_vault_key_id                   = azurerm_key_vault_key.main_cdb_new.versionless_id
  minimal_tls_version                = "Tls12"
  tags                               = merge(var.tags, { data_classification = lower(var.cosmosdb_data_classifcation) })
  # Allow Azure DC IPs and Azure Portal for Cassandra API: https://learn.microsoft.com/en-gb/azure/cosmos-db/how-to-configure-firewall#allow-requests-from-the-azure-portal
  ip_range_filter = [
    "40.113.96.14", "104.42.11.145", "137.117.230.240", "168.61.72.237", "13.88.56.148", "13.91.105.215", "4.210.172.107", "40.91.218.243"
  ]
  virtual_network_rule { id = data.azurerm_subnet.secure_access_uksouth.id }
  virtual_network_rule { id = data.azurerm_subnet.secure_access_centralindia.id }
  dynamic "virtual_network_rule" {
    for_each = toset(local.dxp_regions)

    content {
      id = data.azurerm_subnet.vnet_integration[virtual_network_rule.key].id
    }

  }

  consistency_policy {
    consistency_level       = "ConsistentPrefix"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_location {
    location          = var.az_long_region
    failover_priority = 0
    zone_redundant    = true
  }
  backup {
    type                = "Periodic"
    storage_redundancy  = "Geo"
    interval_in_minutes = 1440
    retention_in_hours  = 168
  }
  capabilities {
    name = "EnableServerless"
  }
  capabilities {
    name = "EnableCassandra"
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-cdb.resource_id]
  }

  depends_on = [time_sleep.kv_rbac]
}

resource "azurerm_management_lock" "main_cosmosdb" {
  count      = var.add_delete_locks ? 1 : 0
  name       = "CanNotDelete"
  scope      = azurerm_cosmosdb_account.main.id
  lock_level = "CanNotDelete"
  notes      = "This resource is locked by Terraform"
}

resource "azurerm_cosmosdb_cassandra_keyspace" "main" {
  name                = "amais_dxp"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_cassandra_keyspace" "staging" {
  name                = "amais_dxp_staging"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}
