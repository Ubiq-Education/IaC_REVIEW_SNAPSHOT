module "dxp_keyvault_uk" {
  source              = "./modules/dxp-keyvault"
  subscription_id     = local.sub_id
  resource_group_name = local.resource_group_name
  az_long_region      = "uksouth"
  network_acl_subnet_ids = concat(
    [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ],
    local.vnet_integration_subnet_ids
  )
}

module "dxp_keyvault_us" {
  source              = "./modules/dxp-keyvault"
  subscription_id     = local.sub_id
  resource_group_name = local.resource_group_name
  az_long_region      = "centralus"
  network_acl_subnet_ids = concat(
    [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ],
    local.vnet_integration_subnet_ids
  )
}

module "dxp_keyvault_canada" {
  source              = "./modules/dxp-keyvault"
  subscription_id     = local.sub_id
  resource_group_name = local.resource_group_name
  az_long_region      = "canadacentral"
  network_acl_subnet_ids = concat(
    [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ],
    local.vnet_integration_subnet_ids
  )
}

module "dxp_keyvault_germany" {
  source              = "./modules/dxp-keyvault"
  subscription_id     = local.sub_id
  resource_group_name = local.resource_group_name
  az_long_region      = "germanywestcentral"
  network_acl_subnet_ids = concat(
    [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ],
    local.vnet_integration_subnet_ids
  )
}

module "dxp_keyvault_uae" {
  source              = "./modules/dxp-keyvault"
  subscription_id     = local.sub_id
  resource_group_name = local.resource_group_name
  az_long_region      = "uaenorth"
  network_acl_subnet_ids = concat(
    [
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ],
    local.vnet_integration_subnet_ids
  )
}
