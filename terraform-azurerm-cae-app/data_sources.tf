data "azurerm_client_config" "current" {}

data "azurerm_container_app_environment" "main" {
  name                = local.parsed_cae_id.resource_name
  resource_group_name = local.parsed_cae_id.resource_group_name
}

data "azurerm_key_vault" "cae" {
  name                = var.cae_details.key_vault_name
  resource_group_name = local.parsed_cae_id.resource_group_name
}

data "azurerm_log_analytics_workspace" "cae" {
  name                = provider::azurerm::parse_resource_id(var.cae_details.log_analytics_workspace_id)["resource_name"]
  resource_group_name = provider::azurerm::parse_resource_id(var.cae_details.log_analytics_workspace_id)["resource_group_name"]
}

data "azurerm_key_vault_secret" "app_secrets" {
  for_each = var.key_vault_secret_ids

  name         = element(split("/", each.value), length(split("/", each.value)) - 1)
  key_vault_id = var.additional_secrets_key_vault_id
}

data "azurerm_user_assigned_identity" "primary_identity" {
  count = var.add_primary_identity != null ? 1 : 0

  name                = local.parsed_identity_id.resource_name
  resource_group_name = local.parsed_identity_id.resource_group_name
}
