output "nat_gateway_pips" {
  description = "List of IP addresses for all NAT gateway public IPs"
  value       = flatten([[for pip in module.regional_network : pip.nat_gateway_pips]])
}

output "network_resource_groups" {
  description = "List of all network resource groups"
  value = {
    for key, rg in azurerm_resource_group.main : key => {
      name     = rg.name
      location = rg.location
    }
  }
}
