data "azurerm_resource_group" "main" {
  name = local.resource_group_name
}

data "azurerm_monitor_action_group" "ubiq_warning" {
  name                = "UBIQWarning"
  resource_group_name = local.ubiq_action_group_rg
}

data "azuread_group" "sql_admins" {
  display_name     = "Azure-RBAC-SQL-Admins"
  security_enabled = true
}

data "azuread_group" "entra_dir_r" {
  display_name     = "Entra-RBAC-SQL-Directory-Readers"
  security_enabled = true
}

data "azurerm_resources" "secure_access_gw_pips" {
  type = "Microsoft.Network/publicIPAddresses"
  required_tags = {
    secure_access_gw = "true"
  }
}

data "azurerm_public_ip" "secure_access_gw_pips" {
  count = length(data.azurerm_resources.secure_access_gw_pips.resources)

  name                = data.azurerm_resources.secure_access_gw_pips.resources[count.index].name
  resource_group_name = data.azurerm_resources.secure_access_gw_pips.resources[count.index].resource_group_name
}

data "azurerm_subnet" "vnet_integration" {
  for_each = toset(local.dxp_regions)

  name                 = "subnet-${module.short_region_lookup[each.key].short_region}-dxp-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${module.short_region_lookup[each.key].short_region}-dxp-01"
  resource_group_name  = "rg-${module.short_region_lookup[each.key].short_region}-ubiq-networking"
}

data "azurerm_key_vault" "dxp" {
  for_each = module.short_region_lookup

  name                = "kv-${each.value.short_region}-amaisdxp"
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_key" "main_sql_uks" {
  name         = azurerm_key_vault_key.main_sql_uks.name
  key_vault_id = data.azurerm_key_vault.dxp["uksouth"].id

  depends_on = [time_sleep.azurerm_key_vault_key_sql]
}

data "azurerm_key_vault_key" "main_sqldb_uks" {
  for_each = local.dxp_sql_dtu_dbs_uks

  name         = azurerm_key_vault_key.main_sqldb_uks[each.key].name
  key_vault_id = data.azurerm_key_vault.dxp["uksouth"].id

  depends_on = [time_sleep.azurerm_key_vault_key_sql]
}

data "azurerm_storage_account" "uks_dxp" {
  name                = "amaisdxp"
  resource_group_name = "Amais-DXP"
}
