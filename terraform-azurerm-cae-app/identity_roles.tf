module "avm-res-managedidentity-userassignedidentity-app" {
  count = var.create_app_instance_identity ? 1 : 0

  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-cae-${local.short_region}-${var.name}"
  resource_group_name = var.global_resource_group_name
  location            = "uksouth"
  tags                = var.tags
}

resource "azurerm_role_assignment" "kv" {
  for_each = local.kv_local_id_roles_map

  scope                = data.azurerm_key_vault.cae.id
  role_definition_name = each.key
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app[0].principal_id
}

resource "azurerm_role_assignment" "additional_container_identity_roles" {
  for_each = var.additional_container_identity_roles

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app[0].principal_id
}

# Add key vault roles to a supplied global identity if specified
resource "azurerm_role_assignment" "kv_global_identity" {
  for_each = local.kv_global_id_roles_map

  scope                = data.azurerm_key_vault.cae.id
  role_definition_name = each.key
  principal_id         = data.azurerm_user_assigned_identity.primary_identity[0].principal_id
}
