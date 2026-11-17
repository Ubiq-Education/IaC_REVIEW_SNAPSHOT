module "regions" {
  source             = "Azure/avm-utl-regions/azurerm"
  version            = "~>0.7.0"
  enable_telemetry   = false
  recommended_filter = false
  region_filter      = [var.az_long_region]
}

module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.az_long_region
}

resource "random_id" "main" {
  byte_length = 16
}

module "ubiq_resources" {
  source  = "api.controlmonkey.io/o-26drsisx9g/ubiq-resources/azapi"
  version = "~>1.0"

  get_securegw_pips  = true
  get_vnets          = true
  get_pum            = true
  get_google_bot_ips = var.google_bot_bypass_enabled
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.formatted_name}"
  location = var.az_long_region
  tags     = merge(var.tags, local.common_tags)
}

resource "time_sleep" "azurerm_managedidentity_all" {
  create_duration = "60s"

  triggers = {
    app_id   = module.avm-res-managedidentity-userassignedidentity-app.resource_id
    sql_id   = module.avm-res-managedidentity-userassignedidentity-sql.resource_id
    sqldb_id = module.avm-res-managedidentity-userassignedidentity-sqldb.resource_id
    st_id    = module.avm-res-managedidentity-userassignedidentity-st.resource_id
  }
}

resource "time_sleep" "kv" {
  create_duration = "60s"

  triggers = {
    kv_id = module.avm-res-keyvault-vault.resource_id
  }
}

resource "azurerm_key_vault_key" "amais" {
  name            = "amais-data-key"
  key_vault_id    = module.avm-res-keyvault-vault.resource_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = merge(var.tags, local.common_tags)

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

  depends_on = [time_sleep.kv]
}

resource "time_sleep" "azurerm_key_vault_key_all" {
  create_duration = "30s"

  triggers = {
    key_main_sql_id   = azurerm_key_vault_key.main_sql.id
    key_main_sqldb_id = azurerm_key_vault_key.main_sqldb.id
    key_main_st_id    = azurerm_key_vault_key.main_st.id
    key_amais_id      = azurerm_key_vault_key.amais.id
  }
}
