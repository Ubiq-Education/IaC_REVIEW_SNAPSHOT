module "avm-res-keyvault-vault" {
  for_each = local.regions

  source                          = "Azure/avm-res-keyvault-vault/azurerm"
  version                         = "~>0.12.0"
  enable_telemetry                = false
  name                            = "kv-${module.short-region-lookup[each.key].short_region}-gf-log-${lower(substr(random_id.main[each.key].hex, 0, 4))}"
  resource_group_name             = azurerm_resource_group.main[each.key].name
  location                        = azurerm_resource_group.main[each.key].location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  sku_name                        = "standard"
  tags                            = local.tags

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      data.azurerm_subnet.amais_central_functions_05[each.key].id,
      data.azurerm_subnet.hub_centralindia_tg.id,
      data.azurerm_subnet.hub_uksouth_tg.id,
      data.azurerm_subnet.hub_uksouth_tf.id,
      data.azurerm_subnet.hub_uksouth_devops_01.id,
      data.azurerm_subnet.hub_uksouth_devops_02.id
    ]
  }

  secrets = {
    loki_password = {
      name = "loki-password"
      tags = local.tags
    }
  }

  secrets_value = {
    loki_password = var.loki_password
  }
}
