data "azurerm_client_config" "current" {}

data "azurerm_subnet" "amais_central_functions_05" {
  for_each = local.regions

  provider             = azurerm.shared
  name                 = "subnet-${module.short-region-lookup[each.key].short_region}-central-functions-05"
  virtual_network_name = "vnet-${module.short-region-lookup[each.key].short_region}-amais-central-01"
  resource_group_name  = "rg-${module.short-region-lookup[each.key].short_region}-ubiq-networking"
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

data "azurerm_subnet" "hub_uksouth_tf" {
  provider             = azurerm.shared
  name                 = "subnet-uks-terraform-agents-ci"
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

data "azurerm_log_analytics_workspace" "shared" {
  provider            = azurerm.shared
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}
