locals {
  block_vnet_inbound = {
    name                       = "BlockVnetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    description                = "Deny all inbound traffic from other VNets"
  }
  allow_azurelb_inbound = {
    name                       = "AllowAzureLBInbound"
    priority                   = 3999
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    description                = "Allow inbound traffic from Azure load balancer"
  }
}
