data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azuread_application" "dxp_api_staging" {
  count        = local.enable_dxp_api_entra_auth_staging ? 1 : 0
  display_name = local.dxp_api_environments["staging"].name
}

data "azuread_service_principal" "dxp_api_staging" {
  count     = local.enable_dxp_api_entra_auth_staging ? 1 : 0
  client_id = data.azuread_application.dxp_api_staging[0].client_id
}

data "azuread_application" "dxp_api_prod" {
  count        = local.enable_dxp_api_entra_auth_prod ? 1 : 0
  display_name = local.dxp_api_environments["prod"].name
}

data "azuread_service_principal" "dxp_api_prod" {
  count     = local.enable_dxp_api_entra_auth_prod ? 1 : 0
  client_id = data.azuread_application.dxp_api_prod[0].client_id
}

data "azurerm_log_analytics_workspace" "shared" {
  provider            = azurerm.shared
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_key_vault" "shared" {
  provider            = azurerm.shared
  name                = "kv-uks-ubiq-shared-res"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "azurerm_key_vault" "main" {
  provider            = azurerm.shared
  name                = local.kv_name
  resource_group_name = local.central_dxp_rg
}

data "azurerm_key_vault_secret" "amais_dxp_superadmin_secret" {
  name         = "sql-uks-amais-dxp-superadmin-secret"
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_service_plan" "main" {
  count = var.use_existing_service_plan ? 1 : 0

  name                = local.sp_name
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_storage_account" "main" {
  for_each = local.storage_accounts_map

  name                = each.value.account_name
  resource_group_name = each.value.storage_resource_group
}

data "azurerm_subnet" "vnet_integration" {
  provider             = azurerm.shared
  name                 = "subnet-${local.short_region}-dxp-01-${local.subnet_identifier}"
  virtual_network_name = "vnet-${local.short_region}-${var.dxp_vnet_alias}"
  resource_group_name  = "rg-${local.short_region}-ubiq-networking"
}

data "azurerm_subnet" "hub_centralindia_tg" {
  provider             = azurerm.shared
  name                 = "subnet-inc-twingate-ci"
  virtual_network_name = "vnet-inc-hub"
  resource_group_name  = "rg-inc-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_tg" {
  provider             = azurerm.shared
  name                 = "subnet-uks-twingate-ci"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_devops_01" {
  provider             = azurerm.shared
  name                 = "subnet-uks-devops-agent-pool-01"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_devops_02" {
  provider             = azurerm.shared
  name                 = "subnet-uks-devops-agent-pool-02"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}

data "azurerm_mssql_server" "dxp" {
  provider            = azurerm.shared
  name                = "amais-dxp"
  resource_group_name = local.central_dxp_rg
}

data "azuread_group" "dxp_cosmos_db_access" {
  display_name     = "Azure-RBAC-DXP-CosmosDB-App-Access"
  security_enabled = true
}

data "azuread_group" "dxp_sql_db_access" {
  display_name     = "DXP-SQL-RBAC-app-identities-RW"
  security_enabled = true
}

data "azuread_group" "dxp_sql_db_access_staging" {
  display_name     = "DXP-SQL-RBAC-app-identities-RW-staging"
  security_enabled = true
}

data "azuread_group" "dxp_app_umi" {
  display_name     = "Azure-RBAC-DXP-App-UMI"
  security_enabled = true
}

data "azuread_group" "dxp_app_umi_staging" {
  display_name     = "Azure-RBAC-DXP-App-UMI-staging"
  security_enabled = true
}

data "azurerm_managed_redis" "main" {
  count = var.redis_cache_enabled ? 1 : 0

  name                = "amr-uks-dxp"
  resource_group_name = local.central_dxp_rg
}
