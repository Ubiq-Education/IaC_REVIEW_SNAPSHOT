module "avm-res-managedidentity-userassignedidentity-redis" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-amr-uks-dxp"
  resource_group_name = lower(local.resource_group_name)
  location            = "uksouth"
  tags                = local.common_tags
}


resource "time_sleep" "identities" {
  create_duration = "30s"

  triggers = {
    redis_id = module.avm-res-managedidentity-userassignedidentity-redis.principal_id
  }
}
