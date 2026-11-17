resource "azurerm_linux_web_app" "main" {
  count = var.web_app_os == "Linux" ? 1 : 0

  name                                           = local.app_name
  resource_group_name                            = azurerm_resource_group.main.name
  location                                       = azurerm_resource_group.main.location
  service_plan_id                                = azurerm_service_plan.main.id
  client_affinity_enabled                        = false # If enabled, clientAffinityProxyEnabled must also be enabled for CDN and WAF (https://github.com/hashicorp/terraform-provider-azurerm/issues/28268)
  https_only                                     = var.https_only_enabled
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  key_vault_reference_identity_id                = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  vnet_image_pull_enabled                        = true
  tags                                           = merge(var.tags, local.common_tags, { "hidden-related:${azurerm_service_plan.main.id}" = "empty" })
  app_settings = merge(
    local.app_settings,
    var.app_settings,
    {
      AzureWebJobsStorage__accountName    = module.avm-res-storage-storageaccount.resource.name
      AzureWebJobsStorage__clientId       = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
      AzureWebJobsStorage__credential     = "managedidentity"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
    }
  )

  identity {
    type = "UserAssigned"
    identity_ids = distinct(compact(flatten([
      module.avm-res-managedidentity-userassignedidentity-app.resource_id,
      local.webapp_additional_identity_ids_prod
    ])))
  }

  site_config {
    app_command_line                  = "dotnet PetraCMS.Web.dll"
    always_on                         = true
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    health_check_path                 = "/HealthCheck/Status"
    health_check_eviction_time_in_min = 10
    minimum_tls_version               = var.minimum_tls_version
    scm_minimum_tls_version           = var.scm_minimum_tls_version
    use_32_bit_worker                 = false
    ip_restriction_default_action     = var.web_app_x_azure_fdid_lockdown ? "Deny" : "Allow"
    scm_ip_restriction_default_action = "Deny"
    vnet_route_all_enabled            = false
    minimum_tls_cipher_suite          = var.min_tls_cipher_suite

    application_stack {
      dotnet_version = trimprefix(var.app_stack_dotnet_version, "v")
    }

    dynamic "cors" {
      for_each = length(var.custom_cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins = var.custom_cors_allowed_origins
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = local.mgmt_subnets
      content {
        name                      = scm_ip_restriction.value.name
        action                    = scm_ip_restriction.value.action
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
      }
    }
  }

  sticky_settings {
    app_setting_names = distinct(concat(local.app_sticky_settings_names, var.app_sticky_settings_names))
  }

  virtual_network_subnet_id = data.azurerm_subnet.vnet_integration.id

  lifecycle {
    # Ignore ip restrictions here and manage them via azapi_update_resource if default action is deny, otherwise managed externally
    ignore_changes = [site_config[0].application_stack[0].dotnet_version, site_config[0].ip_restriction]
  }
}

resource "azapi_update_resource" "main_webapp_properties_linux" {
  count = var.web_app_os == "Linux" ? 1 : 0

  resource_id = azurerm_linux_web_app.main[0].id
  type        = "Microsoft.Web/sites@2025-03-01"
  body = {
    properties = {
      outboundVnetRouting = {
        contentShareTraffic = true
      }
    }
  }
  response_export_values = ["id"]
}

resource "azapi_resource" "main_webapp_webjobs_enabled_linux" {
  count = var.web_app_os == "Linux" ? 1 : 0

  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = "${local.app_name}-webjobs-enabled"
  parent_id = azurerm_resource_group.main.id

  body = {
    properties = {
      mode = "Incremental"
      parameters = {
        webAppName = {
          value = azurerm_linux_web_app.main[0].name
        }
        location = {
          value = azurerm_linux_web_app.main[0].location
        }
        tags = {
          value = azurerm_linux_web_app.main[0].tags
        }
      }
      template = {
        "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        parameters = {
          webAppName = {
            type = "string"
          }
          location = {
            type = "string"
          }
          tags = {
            type = "object"
          }
        }
        resources = [
          {
            type       = "Microsoft.Web/sites"
            apiVersion = "2025-03-01"
            name       = "[parameters('webAppName')]"
            location   = "[parameters('location')]"
            tags       = "[parameters('tags')]"
            properties = {
              siteConfig = {
                webJobsEnabled = true
              }
            }
          }
        ]
      }
    }
  }
}

resource "azurerm_linux_web_app_slot" "main_staging" {
  # There should only be one or zero staging slots
  count = (local.add_staging_slot && var.web_app_os == "Linux") ? 1 : 0

  name                                           = local.staging_slot_name
  app_service_id                                 = azurerm_linux_web_app.main[0].id
  client_affinity_enabled                        = false # If enabled, clientAffinityProxyEnabled must also be enabled for CDN and WAF (https://github.com/hashicorp/terraform-provider-azurerm/issues/28268)
  https_only                                     = var.https_only_enabled_staging
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  key_vault_reference_identity_id                = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  vnet_image_pull_enabled                        = true
  tags                                           = merge(var.tags, local.common_tags)
  app_settings = merge(
    local.app_settings_staging,
    var.app_settings_staging,
    {
      AzureWebJobsStorage__accountName    = module.avm-res-storage-storageaccount.resource.name
      AzureWebJobsStorage__clientId       = module.avm-res-managedidentity-userassignedidentity-app.resource.client_id
      AzureWebJobsStorage__credential     = "managedidentity"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
    }
  )

  identity {
    type = "UserAssigned"
    identity_ids = distinct(compact(flatten([
      module.avm-res-managedidentity-userassignedidentity-app.resource_id,
      local.webapp_additional_identity_ids_staging
    ])))
  }

  site_config {
    app_command_line                  = "dotnet PetraCMS.Web.dll"
    always_on                         = true
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    health_check_path                 = "/HealthCheck/Status"
    health_check_eviction_time_in_min = 10
    minimum_tls_version               = var.minimum_tls_version_staging
    scm_minimum_tls_version           = var.scm_minimum_tls_version_staging
    use_32_bit_worker                 = false
    ip_restriction_default_action     = var.web_app_x_azure_fdid_lockdown ? "Deny" : "Allow"
    scm_ip_restriction_default_action = "Deny"
    vnet_route_all_enabled            = false
    minimum_tls_cipher_suite          = var.min_tls_cipher_suite_staging

    application_stack {
      dotnet_version = trimprefix(var.app_stack_dotnet_version_staging == null ? var.app_stack_dotnet_version : var.app_stack_dotnet_version_staging, "v")
    }

    dynamic "cors" {
      for_each = length(var.custom_cors_allowed_origins) > 0 ? [1] : []
      content {
        allowed_origins = var.custom_cors_allowed_origins
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = local.mgmt_subnets
      content {
        name                      = scm_ip_restriction.value.name
        action                    = scm_ip_restriction.value.action
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
      }
    }
  }

  virtual_network_subnet_id = data.azurerm_subnet.vnet_integration.id

  lifecycle {
    # Ignore ip restrictions here and manage them via azapi_update_resource if default action is deny, otherwise managed externally
    ignore_changes = [site_config[0].application_stack[0].dotnet_version, site_config[0].ip_restriction]
    action_trigger {
      events  = [after_create]
      actions = [action.azureactions_devops_pipeline_trigger.deploy_amais]
    }
  }
}

resource "azapi_update_resource" "main_webapp_staging_properties_linux" {
  count = (local.add_staging_slot && var.web_app_os == "Linux") ? 1 : 0

  resource_id = azurerm_linux_web_app_slot.main_staging[count.index].id
  type        = "Microsoft.Web/sites/slots@2025-03-01"
  body = {
    properties = {
      outboundVnetRouting = {
        contentShareTraffic = true
      }
    }
  }
  response_export_values = ["id"]
}

resource "azapi_resource" "main_webapp_staging_webjobs_enabled_linux" {
  count = (local.add_staging_slot && var.web_app_os == "Linux") ? 1 : 0

  type      = "Microsoft.Resources/deployments@2025-04-01"
  name      = "${local.app_name}-staging-webjobs-enabled"
  parent_id = azurerm_resource_group.main.id

  body = {
    properties = {
      mode = "Incremental"
      parameters = {
        webAppName = {
          value = azurerm_linux_web_app.main[0].name
        }
        slotName = {
          value = azurerm_linux_web_app_slot.main_staging[count.index].name
        }
        location = {
          value = azurerm_linux_web_app.main[0].location
        }
        tags = {
          value = azurerm_linux_web_app_slot.main_staging[count.index].tags
        }
      }
      template = {
        "$schema"      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        parameters = {
          webAppName = {
            type = "string"
          }
          slotName = {
            type = "string"
          }
          location = {
            type = "string"
          }
          tags = {
            type = "object"
          }
        }
        resources = [
          {
            type       = "Microsoft.Web/sites/slots"
            apiVersion = "2025-03-01"
            name       = "[format('{0}/{1}', parameters('webAppName'), parameters('slotName'))]"
            location   = "[parameters('location')]"
            tags       = "[parameters('tags')]"
            properties = {
              siteConfig = {
                webJobsEnabled = true
              }
            }
          }
        ]
      }
    }
  }
}
