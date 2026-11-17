data "azurerm_resource_group" "main" {
  name = local.resource_group_name
}

data "azurerm_container_registry" "main" {
  name                = "cruksubiqshared"
  resource_group_name = "rg-uks-ubiq-shared-res"
}

data "azurerm_key_vault" "main" {
  name                = "kv-uks-amaisdxp"
  resource_group_name = local.resource_group_name
}
