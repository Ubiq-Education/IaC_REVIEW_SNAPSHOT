data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "shared" {
  provider            = azurerm.shared
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_container_registry" "main" {
  provider            = azurerm.shared
  name                = "cruksubiqshared"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "azurerm_key_vault_certificate" "sigr" {
  for_each     = { for region, config in var.regions_enabled : region => config if local.sigr_custom_domain_and_cert_enabled[region] }
  name         = each.value.signalr_config.key_vault_certificate_name
  key_vault_id = module.key_vault[each.key].id
}

data "azurerm_dns_zone" "main" {
  provider            = azurerm.shared
  name                = local.domain_suffix
  resource_group_name = "rg-uks-ubiq-networking"
}

data "azuread_group" "sql_admins" {
  display_name     = "Azure-RBAC-SQL-Admins"
  security_enabled = true
}

data "azuread_group" "entra_dir_r" {
  display_name     = "Entra-RBAC-SQL-Directory-Readers"
  security_enabled = true
}

data "azuread_group" "devs" {
  display_name               = "Azure-RBAC-WKFLO-Developer"
  security_enabled           = true
  include_transitive_members = true
}

data "azurerm_storage_account" "configs" {
  provider            = azurerm.shared
  name                = "st47860a55d730abc11df262"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "http" "staticweb_files" {
  for_each = local.staticweb_files
  url      = "${data.azurerm_storage_account.configs.primary_web_endpoint}${each.value.name}"
  request_headers = {
    Accept = each.value.type
  }
  retry {
    attempts = 3
  }
}

