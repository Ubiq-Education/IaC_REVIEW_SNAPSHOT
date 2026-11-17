# AMAIS NSG Rules
resource "azurerm_network_security_rule" "amais_block_vnet_inbound" {
  for_each = local.nsgs_amais

  name                        = local.block_vnet_inbound.name
  description                 = local.block_vnet_inbound.description
  priority                    = local.block_vnet_inbound.priority
  direction                   = local.block_vnet_inbound.direction
  access                      = local.block_vnet_inbound.access
  protocol                    = local.block_vnet_inbound.protocol
  source_port_range           = local.block_vnet_inbound.source_port_range
  destination_port_range      = local.block_vnet_inbound.destination_port_range
  source_address_prefix       = local.block_vnet_inbound.source_address_prefix
  destination_address_prefix  = local.block_vnet_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "amais_allow_azurelb_inbound" {
  for_each = local.nsgs_amais

  name                        = local.allow_azurelb_inbound.name
  description                 = local.allow_azurelb_inbound.description
  priority                    = local.allow_azurelb_inbound.priority
  direction                   = local.allow_azurelb_inbound.direction
  access                      = local.allow_azurelb_inbound.access
  protocol                    = local.allow_azurelb_inbound.protocol
  source_port_range           = local.allow_azurelb_inbound.source_port_range
  destination_port_range      = local.allow_azurelb_inbound.destination_port_range
  source_address_prefix       = local.allow_azurelb_inbound.source_address_prefix
  destination_address_prefix  = local.allow_azurelb_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

# Twingate NSG Rules
resource "azurerm_network_security_rule" "twingate_block_vnet_inbound" {
  for_each = local.nsgs_twingate

  name                        = local.block_vnet_inbound.name
  description                 = local.block_vnet_inbound.description
  priority                    = local.block_vnet_inbound.priority
  direction                   = local.block_vnet_inbound.direction
  access                      = local.block_vnet_inbound.access
  protocol                    = local.block_vnet_inbound.protocol
  source_port_range           = local.block_vnet_inbound.source_port_range
  destination_port_range      = local.block_vnet_inbound.destination_port_range
  source_address_prefix       = local.block_vnet_inbound.source_address_prefix
  destination_address_prefix  = local.block_vnet_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "twingate_allow_azurelb_inbound" {
  for_each = local.nsgs_twingate

  name                        = local.allow_azurelb_inbound.name
  description                 = local.allow_azurelb_inbound.description
  priority                    = local.allow_azurelb_inbound.priority
  direction                   = local.allow_azurelb_inbound.direction
  access                      = local.allow_azurelb_inbound.access
  protocol                    = local.allow_azurelb_inbound.protocol
  source_port_range           = local.allow_azurelb_inbound.source_port_range
  destination_port_range      = local.allow_azurelb_inbound.destination_port_range
  source_address_prefix       = local.allow_azurelb_inbound.source_address_prefix
  destination_address_prefix  = local.allow_azurelb_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

# Terraform NSG Rules
resource "azurerm_network_security_rule" "terraform_block_vnet_inbound" {
  for_each = local.nsgs_terraform

  name                        = local.block_vnet_inbound.name
  description                 = local.block_vnet_inbound.description
  priority                    = local.block_vnet_inbound.priority
  direction                   = local.block_vnet_inbound.direction
  access                      = local.block_vnet_inbound.access
  protocol                    = local.block_vnet_inbound.protocol
  source_port_range           = local.block_vnet_inbound.source_port_range
  destination_port_range      = local.block_vnet_inbound.destination_port_range
  source_address_prefix       = local.block_vnet_inbound.source_address_prefix
  destination_address_prefix  = local.block_vnet_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "terraform_allow_azurelb_inbound" {
  for_each = local.nsgs_terraform

  name                        = local.allow_azurelb_inbound.name
  description                 = local.allow_azurelb_inbound.description
  priority                    = local.allow_azurelb_inbound.priority
  direction                   = local.allow_azurelb_inbound.direction
  access                      = local.allow_azurelb_inbound.access
  protocol                    = local.allow_azurelb_inbound.protocol
  source_port_range           = local.allow_azurelb_inbound.source_port_range
  destination_port_range      = local.allow_azurelb_inbound.destination_port_range
  source_address_prefix       = local.allow_azurelb_inbound.source_address_prefix
  destination_address_prefix  = local.allow_azurelb_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

# DevOps agent pool NSG Rules
resource "azurerm_network_security_rule" "devops_block_vnet_inbound" {
  for_each = local.nsgs_devops

  name                        = local.block_vnet_inbound.name
  description                 = local.block_vnet_inbound.description
  priority                    = local.block_vnet_inbound.priority
  direction                   = local.block_vnet_inbound.direction
  access                      = local.block_vnet_inbound.access
  protocol                    = local.block_vnet_inbound.protocol
  source_port_range           = local.block_vnet_inbound.source_port_range
  destination_port_range      = local.block_vnet_inbound.destination_port_range
  source_address_prefix       = local.block_vnet_inbound.source_address_prefix
  destination_address_prefix  = local.block_vnet_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "devops_allow_azurelb_inbound" {
  for_each = local.nsgs_devops

  name                        = local.allow_azurelb_inbound.name
  description                 = local.allow_azurelb_inbound.description
  priority                    = local.allow_azurelb_inbound.priority
  direction                   = local.allow_azurelb_inbound.direction
  access                      = local.allow_azurelb_inbound.access
  protocol                    = local.allow_azurelb_inbound.protocol
  source_port_range           = local.allow_azurelb_inbound.source_port_range
  destination_port_range      = local.allow_azurelb_inbound.destination_port_range
  source_address_prefix       = local.allow_azurelb_inbound.source_address_prefix
  destination_address_prefix  = local.allow_azurelb_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

# Central functions NSG Rules
resource "azurerm_network_security_rule" "central_functions_block_vnet_inbound" {
  for_each = local.nsgs_central_functions

  name                        = local.block_vnet_inbound.name
  description                 = local.block_vnet_inbound.description
  priority                    = local.block_vnet_inbound.priority
  direction                   = local.block_vnet_inbound.direction
  access                      = local.block_vnet_inbound.access
  protocol                    = local.block_vnet_inbound.protocol
  source_port_range           = local.block_vnet_inbound.source_port_range
  destination_port_range      = local.block_vnet_inbound.destination_port_range
  source_address_prefix       = local.block_vnet_inbound.source_address_prefix
  destination_address_prefix  = local.block_vnet_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}

resource "azurerm_network_security_rule" "central_functions_allow_azurelb_inbound" {
  for_each = local.nsgs_central_functions

  name                        = local.allow_azurelb_inbound.name
  description                 = local.allow_azurelb_inbound.description
  priority                    = local.allow_azurelb_inbound.priority
  direction                   = local.allow_azurelb_inbound.direction
  access                      = local.allow_azurelb_inbound.access
  protocol                    = local.allow_azurelb_inbound.protocol
  source_port_range           = local.allow_azurelb_inbound.source_port_range
  destination_port_range      = local.allow_azurelb_inbound.destination_port_range
  source_address_prefix       = local.allow_azurelb_inbound.source_address_prefix
  destination_address_prefix  = local.allow_azurelb_inbound.destination_address_prefix
  resource_group_name         = each.value.resource_group_name
  network_security_group_name = each.value.name
}
