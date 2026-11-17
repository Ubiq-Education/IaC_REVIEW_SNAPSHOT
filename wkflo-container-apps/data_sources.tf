data "azurerm_client_config" "current" {}

data "azurerm_subscriptions" "ai_subs" {
  # Only query for AI relevant subscriptions if the feature is enabled to reduce plan time
  count = var.azure_ai_model_access_enabled ? 1 : 0

  display_name_prefix = "UBIQAI"
}

data "azurerm_log_analytics_workspace" "shared" {
  provider            = azurerm.shared
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_key_vault" "central" {
  provider            = azurerm.shared
  name                = "kv-uks-amais-central"
  resource_group_name = "rg-uks-amais-central"
}

data "azurerm_key_vault" "main" {
  name                = provider::azurerm::parse_resource_id(local.cae_key_vault_id)["resource_name"]
  resource_group_name = provider::azurerm::parse_resource_id(local.cae_key_vault_id)["resource_group_name"]
}

data "azurerm_mssql_server" "wkflo" {
  count = var.wkflo_sql_db_connection_enabled ? 1 : 0

  name                = provider::azurerm::parse_resource_id(local.cae_wkflo_mssql_resource.server_id)["resource_name"]
  resource_group_name = provider::azurerm::parse_resource_id(local.cae_wkflo_mssql_resource.server_id)["resource_group_name"]
}

data "azurerm_key_vault_secret" "elasticsearch_api_key" {
  count = var.elastic_search_connections.standard_enabled ? 1 : 0

  name         = "wkflo-elastic-${var.environment}-api-key"
  key_vault_id = data.azurerm_key_vault.central.id
}

data "azurerm_key_vault_secret" "serilog_elasticsearch_api_key" {
  count = var.elastic_search_connections.serilog_enabled ? 1 : 0

  # Currently same as standard elastic search api key, but separate in case we want to use a different ELK stack for serilog logs in the future
  name         = "wkflo-elastic-${var.environment}-api-key"
  key_vault_id = data.azurerm_key_vault.central.id
}

data "azurerm_key_vault_secret" "eis_elasticsearch_api_key" {
  count = var.elastic_search_connections.eis_enabled ? 1 : 0

  name         = "wkflo-eis-elastic-${var.environment}-api-key"
  key_vault_id = data.azurerm_key_vault.central.id
}

data "azurerm_key_vault_secret" "mcp_oauth_token_encryption_key" {
  count = var.mcp_oauth_token_encryption_enabled ? 1 : 0

  name         = "wkflo-mcp-oauth-token-encryption-key-${var.environment}"
  key_vault_id = data.azurerm_key_vault.central.id
}

data "azurerm_dns_zone" "main" {
  for_each = var.bunny_hostnames

  provider            = azurerm.shared
  name                = endswith(each.value, ".amais.com") ? "amais.com" : "wkflo.ai"
  resource_group_name = "rg-uks-ubiq-networking"
}

data "azuread_group" "sql_rw" {
  display_name     = "${provider::azurerm::parse_resource_id(local.cae_id)["resource_name"]}-SQL-RBAC-RW"
  security_enabled = true
}

data "azuread_application" "dxp_api" {
  count     = local.dxp_client_identity_enabled ? 1 : 0
  object_id = local.dxp_client[var.environment].api_application_object_id
}
