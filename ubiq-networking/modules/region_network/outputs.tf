output "nat_gateway_pips" {
  description = "List of IP addresses for all NAT gateway public IPs"
  value       = [for pip in data.azurerm_public_ip.main : pip.ip_address]
}
