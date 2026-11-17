module "avm-res-managedidentity-userassignedidentity-wkflo-amais-client" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-app-uks-amais-wkflo-client-${var.environment}"
  resource_group_name = azurerm_resource_group.shared.name
  location            = "uksouth"
  tags                = local.tags
}

resource "azuread_app_role_assignment" "wkflo_clients" {
  for_each = local.main_app_roles

  app_role_id         = each.key
  principal_object_id = module.avm-res-managedidentity-userassignedidentity-wkflo-amais-client.principal_id
  resource_object_id  = azuread_service_principal.main.object_id
}

resource "azuread_app_role_assignment" "wkflo_devs" {
  for_each = { for role, config in local.main_app_roles : role => config if local.is_staging }

  app_role_id         = each.key
  principal_object_id = data.azuread_group.devs.object_id
  resource_object_id  = azuread_service_principal.main.object_id
}
