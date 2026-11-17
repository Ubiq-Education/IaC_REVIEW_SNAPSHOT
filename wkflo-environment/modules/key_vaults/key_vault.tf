module "avm-res-keyvault-vault" {
  source                          = "Azure/avm-res-keyvault-vault/azurerm"
  version                         = "~>0.12.0"
  enable_telemetry                = false
  name                            = var.kv_name
  resource_group_name             = var.resource_group_name
  location                        = var.az_long_region
  tenant_id                       = var.azurerm_client_config_current_tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = true
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  sku_name                        = "standard"
  tags                            = var.tags
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = var.network_acls_default_action
    virtual_network_subnet_ids = var.network_acls_virtual_network_subnet_ids
  }
}
