output "nat_gateway_pips" {
  description = "List of IP addresses for all NAT gateway public IPs"
  value       = [for pip in data.azurerm_public_ip.main : pip.ip_address]
}

output "subnets" {
  value = azurerm_subnet.main
}

output "virtual_networks" {
  value = azurerm_virtual_network.main
}

output "region_nw" {
  value = local.region_nw
}
