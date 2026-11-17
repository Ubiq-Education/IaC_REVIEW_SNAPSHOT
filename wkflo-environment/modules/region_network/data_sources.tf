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
