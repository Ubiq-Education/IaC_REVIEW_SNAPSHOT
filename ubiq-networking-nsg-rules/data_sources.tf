data "azurerm_resources" "nsgs" {
  for_each = var.network_resource_groups

  resource_group_name = each.value.name
  type                = "Microsoft.Network/networkSecurityGroups"
}
