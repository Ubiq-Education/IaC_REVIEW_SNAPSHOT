resource "random_id" "main" {
  for_each = var.regions_enabled

  byte_length = 16
}

module "short-region-lookup" {
  # for_each region map should match the regions defined in local.cae_regions to ensure correct lookup elsewhere
  for_each = var.regions_enabled

  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = each.key
}

module "ubiq_resources" {
  source  = "api.controlmonkey.io/o-26drsisx9g/ubiq-resources/azapi"
  version = "~>1.0"

  get_securegw_pips = true
  get_vnets         = true
}

resource "azurerm_resource_group" "main" {
  for_each = var.regions_enabled

  name     = "rg-${module.short-region-lookup[each.key].short_region}-wkflo-cae-${var.environment}"
  location = each.key
  tags     = local.tags
}

resource "azurerm_resource_group" "apps" {
  for_each = var.regions_enabled

  name     = "rg-${module.short-region-lookup[each.key].short_region}-wkflo-cae-apps-${var.environment}"
  location = each.key
  tags     = local.tags
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-global-wkflo-cae-${var.environment}"
  location = "uksouth"
  tags     = local.tags
}

module "key_vault" {
  for_each = var.regions_enabled

  source                                  = "./modules/key_vaults"
  kv_name                                 = "kv-${local.cae_names[each.key]}"
  resource_group_name                     = azurerm_resource_group.main[each.key].name
  az_long_region                          = each.key
  azurerm_client_config_current_tenant_id = data.azurerm_client_config.current.tenant_id
  tags                                    = local.tags
  kv_certificate_user_principal_ids = {
    cae_umi = module.avm-res-managedidentity-userassignedidentity-cae[each.key].principal_id
  }
  kv_crypto_service_encryption_user_principal_ids = {
    cae_umi    = module.avm-res-managedidentity-userassignedidentity-cae[each.key].principal_id
    redis_umi  = module.avm-res-managedidentity-userassignedidentity-redis[each.key].principal_id
    sql_umi    = module.avm-res-managedidentity-userassignedidentity-sql[each.key].principal_id
    sqldb_umi  = module.avm-res-managedidentity-userassignedidentity-sqldb[each.key].principal_id
    sbns_umi   = module.avm-res-managedidentity-userassignedidentity-sbns[each.key].principal_id
    st_umi     = module.avm-res-managedidentity-userassignedidentity-st[each.key].principal_id
    pgsql_umi  = module.avm-res-managedidentity-userassignedidentity-pgsql[each.key].principal_id
    net_st_umi = module.avm-res-managedidentity-userassignedidentity-st-netflowlogs[each.key].principal_id
  }
  kv_secret_user_principal_ids = merge(
    {
      cae_umi = module.avm-res-managedidentity-userassignedidentity-cae[each.key].principal_id
    },
    local.is_staging ? {
      developer = data.azuread_group.devs.object_id
    } : {}
  )
  key_names = {
    redis_cmk  = "amr-${local.cae_names[each.key]}-key"
    sql_tde    = "sql-${local.cae_names[each.key]}-key"
    sqldb_tde  = "sqldb-${local.cae_names[each.key]}-key"
    st_cmk     = "st${lower(substr(random_id.main[each.key].hex, 0, 22))}-key"
    sbns_cmk   = "sbns-${local.cae_names[each.key]}-key"
    pgsql_cmk  = "pgsql-${local.cae_names[each.key]}-key"
    net_st_cmk = "st${lower(substr(random_id.netflowlog[each.key].hex, 0, 22))}-key"
  }

  network_acls_virtual_network_subnet_ids = distinct(compact(concat(
    [module.regional_network[each.key].subnets["wkflo-01:cae-01"].id],
    [for subnet in module.ubiq_resources.twingate_subnets : subnet.id],
    [for subnet in module.ubiq_resources.devops_subnets : subnet.id],
    [for subnet in module.ubiq_resources.terraform_subnets : subnet.id]
  )))

  depends_on = [time_sleep.azurerm_userassignedidentity_all]
}

# TODO: Move this module to the registry and call from here and the main networking stack
module "regional_network" {
  for_each = var.regions_enabled

  providers = {
    azurerm        = azurerm
    azurerm.shared = azurerm.shared
  }
  source              = "./modules/region_network"
  az_long_region      = each.key
  resource_group_name = azurerm_resource_group.main[each.key].name
  tags                = local.tags
  vnet_configurations = local.cae_regions[each.key].vnets
}

resource "azapi_resource" "network_watcher_flow_log" {
  for_each = local.network_watcher_flow_logs_map

  type      = "Microsoft.Network/networkWatchers/flowLogs@2025-05-01"
  name      = "${each.value.vnet_name}-flow-log-${var.environment}"
  parent_id = module.regional_network[each.value.region].region_nw.id
  location  = each.value.region
  tags      = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [module.avm-res-managedidentity-userassignedidentity-nwfl[each.value.region].resource_id]
  }

  body = {
    properties = {
      enabled = true
      retentionPolicy = {
        days    = 7
        enabled = true
      }
      storageId        = module.avm-res-storage-storageaccount-netflowlogs[each.value.region].resource_id
      targetResourceId = module.regional_network[each.value.region].virtual_networks[each.value.vnet_key].id
    }
  }
}
