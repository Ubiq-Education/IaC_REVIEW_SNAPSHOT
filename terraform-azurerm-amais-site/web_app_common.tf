module "avm-res-managedidentity-userassignedidentity-app" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = local.app_mi_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = merge(var.tags, local.common_tags)
}

resource "azuread_group_member" "app_amais_umi" {
  group_object_id  = data.azuread_group.amais_app_umi.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_service_plan" "main" {
  name                   = local.asp_name
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  os_type                = var.web_app_os
  sku_name               = var.service_plan_sku
  zone_balancing_enabled = local.app_zone_redundant
  worker_count           = local.app_zone_redundant ? local.app_instance_count : null
  tags                   = merge(var.tags, local.common_tags)
}

# Only add the ip restrictions if using deny by default to allow block rules to be externally added if default is allow
resource "azapi_update_resource" "main_webapp_properties_restrictions_deny" {
  count = var.web_app_x_azure_fdid_lockdown ? 1 : 0

  resource_id = local.web_app_resource_id
  type        = "Microsoft.Web/sites@2024-11-01"
  body = {
    properties = {
      siteConfig = {
        ipSecurityRestrictions : concat(
          [
            {
              action    = "Allow"
              headers   = { X-Azure-FDID = [local.x_azure_fdid_value] }
              ipAddress = "0.0.0.0/0"
              name      = "AllowBunny"
              priority  = 100
            },
            {
              action    = "Allow"
              headers   = { X-Azure-FDID = [local.x_azure_fdid_value] }
              ipAddress = "::0/0"
              name      = "AllowBunnyIPv6"
              priority  = 110
            }
          ],
          [for i, subnet in concat(
            values(module.ubiq_resources.twingate_subnets),
            values(module.ubiq_resources.devops_subnets)
            ) : {
            action               = "Allow"
            vnetSubnetResourceId = subnet.id
            name                 = subnet.name
            priority             = 120 + (i * 10)
            }
          ]
        )
      }
    }
  }

  response_export_values = ["id"]
  depends_on = [
    azapi_update_resource.main_webapp_properties,
    azapi_update_resource.main_webapp_properties_linux,
  ]
}

# Only add the ip restrictions if using deny by default to allow block rules to be externally added if default is allow
resource "azapi_update_resource" "main_webapp_staging_properties_restrictions_deny" {
  count = (local.add_staging_slot && var.web_app_x_azure_fdid_lockdown) ? 1 : 0

  resource_id = local.web_app_staging_slot_ids[count.index]
  type        = "Microsoft.Web/sites/slots@2024-11-01"
  body = {
    properties = {
      siteConfig = {
        ipSecurityRestrictions : concat(
          [
            {
              action    = "Allow"
              headers   = { X-Azure-FDID = [local.x_azure_fdid_value] }
              ipAddress = "0.0.0.0/0"
              name      = "AllowBunny"
              priority  = 100
            },
            {
              action    = "Allow"
              headers   = { X-Azure-FDID = [local.x_azure_fdid_value] }
              ipAddress = "::0/0"
              name      = "AllowBunnyIPv6"
              priority  = 110
            }
          ],
          [for i, subnet in concat(
            values(module.ubiq_resources.twingate_subnets),
            values(module.ubiq_resources.devops_subnets)
            ) : {
            action               = "Allow"
            vnetSubnetResourceId = subnet.id
            name                 = subnet.name
            priority             = 120 + (i * 10)
            }
          ]
        )
      }
    }
  }

  response_export_values = ["id"]
  depends_on = [
    azapi_update_resource.main_webapp_staging_properties,
    azapi_update_resource.main_webapp_staging_properties_linux,
  ]
}
