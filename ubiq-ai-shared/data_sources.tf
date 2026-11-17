data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "shared" {
  provider            = azurerm.shared
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
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

data "azuread_group" "amais_app_umi" {
  display_name     = "Azure-RBAC-AMAIS-App-UMI"
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

data "azuread_group" "aidev" {
  display_name     = "Azure-RBAC-AI-Developer"
  security_enabled = true
}

data "azurerm_user_assigned_identity" "ais_srch" {
  provider            = azurerm.shared
  name                = "id-ais-uks-ai-central"
  resource_group_name = "rg-uks-ai-central"
}

data "azurerm_dns_zone" "amais_com" {
  provider            = azurerm.shared
  name                = "amais.com"
  resource_group_name = "rg-uks-ubiq-networking"
}
