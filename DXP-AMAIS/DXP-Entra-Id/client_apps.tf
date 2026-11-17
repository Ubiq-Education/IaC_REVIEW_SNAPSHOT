# AMAIS client

module "avm-res-managedidentity-userassignedidentity-dxp-clients" {
  for_each = local.main_app_environments

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-app-uks-amais-dxp-client-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.az_region
  tags                = each.key == "dev" ? local.dev_tags : local.common_tags
}


resource "azuread_app_role_assignment" "dxp_clients" {
  for_each = local.all_main_app_roles

  app_role_id         = each.value.app_role_id
  principal_object_id = module.avm-res-managedidentity-userassignedidentity-dxp-clients[each.value.app_key].principal_id
  resource_object_id  = azuread_service_principal.main[each.value.app_key].object_id
}

# Wkflo client

module "avm-res-managedidentity-userassignedidentity-dxp-clients-wkflo" {
  for_each = local.main_app_environments

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-app-uks-wkflo-dxp-client-${each.key}"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.az_region
  tags                = each.key == "dev" ? local.dev_tags : local.common_tags
}


resource "azuread_app_role_assignment" "dxp_clients_wkflo" {
  for_each = local.all_main_app_roles

  app_role_id         = each.value.app_role_id
  principal_object_id = module.avm-res-managedidentity-userassignedidentity-dxp-clients-wkflo[each.value.app_key].principal_id
  resource_object_id  = azuread_service_principal.main[each.value.app_key].object_id
}

# Developer group - staging

resource "azuread_app_role_assignment" "dxp_clients_dev_staging" {
  for_each = local.main_app_roles

  app_role_id         = each.key
  principal_object_id = local.entra_groups.azure_rbac_dxp_platform_staging_all
  resource_object_id  = azuread_service_principal.main["staging"].object_id
}
