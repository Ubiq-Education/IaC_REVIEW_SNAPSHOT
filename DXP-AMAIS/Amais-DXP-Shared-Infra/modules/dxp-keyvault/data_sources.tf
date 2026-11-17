data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "shared" {
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}
