module "short_region_lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = var.az_long_region
}

module "regions" {
  source                   = "Azure/regions/azurerm"
  version                  = "~>0.8.2"
  recommended_regions_only = false
}

resource "azurerm_virtual_network" "main" {
  for_each = var.vnet_configurations

  name                = "vnet-${module.short_region_lookup.short_region}-${each.key}"
  resource_group_name = var.resource_group_name
  location            = var.az_long_region
  address_space       = each.value.address_space
  tags                = var.tags
}

resource "time_sleep" "vnet_configurations" {
  create_duration = "60s"

  triggers = {
    vnet_ids = join(",", [for vnet in values(azurerm_virtual_network.main) : vnet.id])
  }
}

resource "azurerm_subnet" "main" {
  for_each = local.subnet_map

  name                 = "subnet-${module.short_region_lookup.short_region}-${each.value.subnet_key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[each.value.vnet_key].name
  address_prefixes     = each.value.subnet_value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.subnet_value.service_delegation_name != null ? [1] : []

    content {
      name = "delegation"

      service_delegation {
        name = each.value.subnet_value.service_delegation_name
      }
    }
  }

  service_endpoints = concat(each.value.subnet_value.service_endpoints, local.default_service_endpoints)

  lifecycle {
    ignore_changes = [
      delegation[0].service_delegation[0].actions
    ]
  }
}

resource "azurerm_network_security_group" "main" {
  for_each = local.subnet_map

  name                = "nsg-${module.short_region_lookup.short_region}-${each.value.subnet_key}"
  resource_group_name = var.resource_group_name
  location            = var.az_long_region
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = local.subnet_map

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.main[each.key].id
}

resource "azurerm_public_ip" "main" {
  for_each = local.nat_gateway_pips

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  location                = var.az_long_region
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 30
  tags                    = each.value.used_for_secure_access == false ? var.tags : merge(var.tags, local.nat_gateway_secure_access_tag)
}

resource "azurerm_nat_gateway" "main" {
  for_each = local.vnet_nat_gateways

  name                    = each.value.name
  resource_group_name     = var.resource_group_name
  location                = var.az_long_region
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = each.value.used_for_secure_access == false ? var.tags : merge(var.tags, local.nat_gateway_secure_access_tag)
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  for_each = local.nat_gateway_pips

  nat_gateway_id       = azurerm_nat_gateway.main[each.value.vnet_key].id
  public_ip_address_id = azurerm_public_ip.main[each.key].id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each = { for item in local.nat_gateway_subnets : "${item.vnet_key}:${item.subnet_key}" => item }

  subnet_id      = azurerm_subnet.main[each.key].id
  nat_gateway_id = azurerm_nat_gateway.main[each.value.vnet_key].id
}

resource "azurerm_role_assignment" "vnet" {
  for_each = { for item in local.vnet_role_assignments : "${item.vnet_key}:${item.identity_id}:${item.role_name}" => item }

  scope                = azurerm_virtual_network.main[each.value.vnet_key].id
  role_definition_name = each.value.role_name
  principal_id         = each.value.identity_id
}

module "monitoring_diagnostics" {
  source  = "api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm"
  version = "~>1.0"
  diagnostics_destinations = {
    log_analytics = {
      enabled = true
    }
  }
  nat_gateways = {
    for gw in local.vnet_nat_gateways : gw.name => {
      resource_id   = azurerm_nat_gateway.main[gw.vnet_key].id
      allocated_ips = length([for pip in local.nat_gateway_pips : pip if pip.vnet_key == gw.vnet_key])
    }
  }
  tags = var.tags
}
