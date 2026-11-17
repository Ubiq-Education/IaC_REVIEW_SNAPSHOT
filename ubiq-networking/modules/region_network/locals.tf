locals {
  az_region_details         = module.regions.regions_by_name_or_display_name[var.az_long_region]
  az_region_zones           = length(coalesce(local.az_region_details.zones, [])) > 0 ? length(local.az_region_details.zones) : 0
  st_name                   = "st${lower(substr(random_id.main.hex, 0, 22))}"
  st_id_name                = "id-${local.st_name}"
  default_service_endpoints = ["Microsoft.Storage.Global"]
  region_nw = values({
    for resource in data.azurerm_resources.nw.resources :
    resource.name => resource
    if resource.location == var.az_long_region
  })[0]
  nat_gateway_secure_access_tag = {
    secure_access_gw = "true"
  }
  subnet_map = merge([
    for vnet, vnet_value in var.vnet_configurations : {
      for subnet, subnet_value in vnet_value.subnets : "${vnet}:${subnet}" => {
        vnet_key     = vnet
        vnet_value   = vnet_value
        subnet_key   = subnet
        subnet_value = subnet_value
      }
    }
  ]...)
  vnet_nat_gateways = {
    for vnet, vnet_value in var.vnet_configurations : vnet => {
      vnet_key               = vnet
      name                   = "ng-${module.short_region_lookup.short_region}-${vnet}-01"
      pip_count              = vnet_value.nat_gateway_pip_count
      used_for_secure_access = vnet_value.nat_gateway_used_for_secure_access
      subnets                = vnet_value.subnets
    } if vnet_value.nat_gateway
  }
  nat_gateway_pips = {
    for idx, pip in flatten([
      for gw, gw_value in local.vnet_nat_gateways : [
        for i in range(gw_value.pip_count) : {
          vnet_key               = gw_value.vnet_key
          name                   = "pip-${gw_value.name}-${format("%02d", i + 1)}"
          gw_name                = gw_value.name
          used_for_secure_access = gw_value.used_for_secure_access
        }
      ]
    ]) : tostring(idx) => pip
  }
  nat_gateway_subnets = flatten([
    for vnet, vnet_value in local.vnet_nat_gateways : [
      for subnet, subnet_value in vnet_value.subnets : {
        vnet_key   = vnet
        subnet_key = subnet
      } if subnet_value.associate_nat_gateway
    ]
  ])
  vnet_role_assignments = flatten([
    for vnet, vnet_value in var.vnet_configurations : [
      for identity, role_value in vnet_value.role_assignments : [
        for role in role_value.role_names : {
          vnet_key    = vnet
          identity_id = identity
          role_name   = role
        }
      ]
    ] if length(vnet_value.role_assignments) > 0
  ])
}
