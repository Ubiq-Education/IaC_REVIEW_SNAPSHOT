# Retrieve the public IP addresses after creation for output
data "azurerm_public_ip" "main" {
  for_each = local.nat_gateway_pips

  name                = each.value.name
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_public_ip.main]
}

data "azurerm_resources" "nw" {
  resource_group_name = "NetworkWatcherRG"
  type                = "Microsoft.Network/networkWatchers"

  # Network watchers are created automatically per region when a VNET is first deployed to a region
  depends_on = [time_sleep.vnet_configurations]
}

data "azurerm_key_vault" "shared" {
  name                = "kv-uks-ubiq-shared-res"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "azurerm_log_analytics_workspace" "main" {
  name                = "log-uks-ubiq-shared-logging"
  resource_group_name = "rg-uks-ubiq-shared-logging"
}

data "azurerm_subnet" "hub_centralindia_tg" {
  name                 = "subnet-inc-twingate-ci"
  virtual_network_name = "vnet-inc-hub"
  resource_group_name  = "rg-inc-ubiq-networking"
}

data "azurerm_subnet" "hub_uksouth_tg" {
  name                 = "subnet-uks-twingate-ci"
  virtual_network_name = "vnet-uks-hub"
  resource_group_name  = "rg-uks-ubiq-networking"
}
