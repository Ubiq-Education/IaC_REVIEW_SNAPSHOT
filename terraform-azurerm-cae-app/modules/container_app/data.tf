data "azurerm_resource_group" "parent" {
  name = var.resource_group_name
}

data "azurerm_container_app_environment" "cae" {
  name                = split("/", var.cae_resource_id)[8]
  resource_group_name = split("/", var.cae_resource_id)[4]
}
