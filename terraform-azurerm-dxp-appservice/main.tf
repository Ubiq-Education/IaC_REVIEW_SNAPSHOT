module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.az_long_region
}

module "avm-res-managedidentity-userassignedidentity-app" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-app-${local.formatted_name}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.az_long_region
  tags                = local.tags

  lock = {
    name = "CanNotDelete"
    kind = "CanNotDelete"
  }
}

module "avm-res-managedidentity-userassignedidentity-app-staging" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-app-${local.formatted_name}-staging"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.az_long_region
  tags                = local.tags

  lock = {
    name = "CanNotDelete"
    kind = "CanNotDelete"
  }
}

resource "time_sleep" "azurerm_managedidentity_all" {
  create_duration = "60s"

  triggers = {
    app_id         = module.avm-res-managedidentity-userassignedidentity-app.resource_id
    app_id_staging = module.avm-res-managedidentity-userassignedidentity-app-staging.resource_id
  }
}

resource "azuread_group_member" "app_dxp_umi" {
  group_object_id  = data.azuread_group.dxp_app_umi.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azuread_group_member" "app_dxp_umi_staging" {
  group_object_id  = data.azuread_group.dxp_app_umi_staging.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azuread_group_member" "app_cosmos_db_access" {
  count = var.add_global_cosmos_db_connection_info == true ? 1 : 0

  group_object_id  = data.azuread_group.dxp_cosmos_db_access.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azuread_group_member" "app_cosmos_db_access_staging" {
  count = var.add_global_cosmos_db_connection_info == true ? 1 : 0

  group_object_id  = data.azuread_group.dxp_cosmos_db_access.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azuread_group_member" "app_sql_db_access" {
  group_object_id  = data.azuread_group.dxp_sql_db_access.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azuread_group_member" "app_sql_db_access_staging" {
  group_object_id  = data.azuread_group.dxp_sql_db_access_staging.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_managed_redis_access_policy_assignment" "app_redis" {
  count = var.redis_cache_enabled ? 1 : 0

  managed_redis_id = data.azurerm_managed_redis.main[0].id
  object_id        = module.avm-res-managedidentity-userassignedidentity-app.principal_id
}

resource "azurerm_managed_redis_access_policy_assignment" "app_staging_redis" {
  count = var.redis_cache_enabled ? 1 : 0

  managed_redis_id = data.azurerm_managed_redis.main[0].id
  object_id        = module.avm-res-managedidentity-userassignedidentity-app-staging.principal_id
}
