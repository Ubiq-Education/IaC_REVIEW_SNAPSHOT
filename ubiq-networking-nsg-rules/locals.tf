locals {
  sub_id = "c94f8a3d-8d0b-4660-85de-26004f233dbf"

  # NSG collections
  nsgs_amais = {
    for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
    "${nsg.resource_group_name}-${nsg.name}" => nsg
    if can(regex(".*-amais-[^hd].*", nsg.name))
    # Exclude AMAIS HD environment subnets
  }
  ## Currently no custom rules for DXP but local added for future use
  # nsgs_dxp = {
  #   for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
  #   "${nsg.resource_group_name}-${nsg.name}" => nsg
  #   if can(regex(".*-dxp-.*", nsg.name))
  # }
  nsgs_twingate = {
    for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
    "${nsg.resource_group_name}-${nsg.name}" => nsg
    if can(regex(".*-twingate-.*", nsg.name))
  }
  nsgs_terraform = {
    for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
    "${nsg.resource_group_name}-${nsg.name}" => nsg
    if can(regex(".*-terraform-agents-.*", nsg.name))
  }
  nsgs_devops = {
    for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
    "${nsg.resource_group_name}-${nsg.name}" => nsg
    if can(regex(".*-devops-agent-pool-.*", nsg.name))
  }
  nsgs_central_functions = {
    for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
    "${nsg.resource_group_name}-${nsg.name}" => nsg
    if can(regex(".*-central-functions-.*", nsg.name))
  }
  ## Currently no custom rules for CAE's but local added for future use
  # nsgs_amais_hd_cae = {
  #   for nsg in flatten([for rg in data.azurerm_resources.nsgs : rg.resources]) :
  #   "${nsg.resource_group_name}-${nsg.name}" => nsg
  #   if can(regex(".*-amais-hd-.*", nsg.name))
  # }
}
