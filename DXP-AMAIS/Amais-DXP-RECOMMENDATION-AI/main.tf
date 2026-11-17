module "short-region-lookup" {
  source         = "api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm"
  version        = "~>1.0.0"
  az_long_region = local.az_long_region
}

module "avm-res-managedidentity-userassignedidentity-app" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "~>0.3"
  enable_telemetry    = false
  name                = "id-app-${local.formatted_name}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.az_long_region
  tags                = local.common_tags

  lock = {
    name = "CanNotDelete"
    kind = "CanNotDelete"
  }
}

resource "time_sleep" "azurerm_managedidentity_all" {
  create_duration = "60s"

  triggers = {
    app_id = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  }
}

resource "azuread_group_member" "app_dxp_umi" {
  group_object_id  = data.azuread_group.dxp_app_umi.object_id
  member_object_id = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on       = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_role_assignment" "main_app_blob_data_contributor" {
  scope                = data.azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.avm-res-managedidentity-userassignedidentity-app.principal_id
  depends_on           = [time_sleep.azurerm_managedidentity_all]
}

resource "azurerm_service_plan" "main" {
  name                   = local.sp_name
  resource_group_name    = data.azurerm_resource_group.main.name
  location               = local.az_long_region
  os_type                = "Linux"
  sku_name               = local.service_plan_sku
  zone_balancing_enabled = false
  worker_count           = local.app_zone_redundant ? local.app_instance_count : null
  tags                   = local.common_tags
}

resource "azurerm_linux_web_app" "main" {
  name                                           = local.app_name
  resource_group_name                            = data.azurerm_resource_group.main.name
  location                                       = local.az_long_region
  service_plan_id                                = azurerm_service_plan.main.id
  client_affinity_enabled                        = false
  https_only                                     = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  key_vault_reference_identity_id                = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  vnet_image_pull_enabled                        = true
  tags                                           = local.common_tags
  app_settings = {
    AZURE_CLIENT_ID                       = module.avm-res-managedidentity-userassignedidentity-app.client_id
    WEBSITE_STARTUP_FILE                  = "startup.sh"
    FLASK_ENV                             = "Production"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "true"
    SCM_ZIPDEPLOY_DONOT_PRESERVE_FILETIME = "1"
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.avm-res-managedidentity-userassignedidentity-app.resource_id
    ]
  }

  site_config {
    always_on                         = true
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    scm_minimum_tls_version           = "1.2"
    use_32_bit_worker                 = true
    ip_restriction_default_action     = "Allow" # TODO: Can this be locked down?
    scm_ip_restriction_default_action = "Deny"
    app_command_line                  = "startup.sh"
    minimum_tls_cipher_suite          = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    application_stack {
      python_version = 3.11
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_centralindia_tg.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_centralindia_tg.id
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_uksouth_tg.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_uksouth_tg.id
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_uksouth_devops_01.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_uksouth_devops_01.id
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_uksouth_devops_02.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_uksouth_devops_02.id
    }
  }

  sticky_settings {
    app_setting_names = [
      "AZURE_CLIENT_ID",
      "SCM_DO_BUILD_DURING_DEPLOYMENT",
      "SCM_ZIPDEPLOY_DONOT_PRESERVE_FILETIME",
      "WEBSITES_PORT",
      "FLASK_ENV",
      "WEBSITE_SITE_NAME"
    ]
  }

  virtual_network_subnet_id = data.azurerm_subnet.vnet_integration.id

}

resource "azapi_update_resource" "main_webapp_properties" {
  resource_id = azurerm_linux_web_app.main.id
  type        = "Microsoft.Web/sites@2024-04-01"
  body = {
    properties = {
      vnetContentShareEnabled : true
    }
  }
}

resource "azurerm_linux_web_app_slot" "main_staging" {
  name                                           = "staging"
  app_service_id                                 = azurerm_linux_web_app.main.id
  client_affinity_enabled                        = false
  https_only                                     = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  key_vault_reference_identity_id                = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  vnet_image_pull_enabled                        = true
  tags                                           = local.common_tags
  app_settings = {
    AZURE_CLIENT_ID                       = module.avm-res-managedidentity-userassignedidentity-app.client_id
    WEBSITE_STARTUP_FILE                  = "startup.sh"
    FLASK_ENV                             = "Staging"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "true"
    SCM_ZIPDEPLOY_DONOT_PRESERVE_FILETIME = "1"
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb   = 35
      }
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.avm-res-managedidentity-userassignedidentity-app.resource_id
    ]
  }

  site_config {
    always_on                         = false
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    scm_minimum_tls_version           = "1.2"
    use_32_bit_worker                 = true
    ip_restriction_default_action     = "Allow" # TODO: Can this be locked down?
    scm_ip_restriction_default_action = "Deny"
    app_command_line                  = "startup.sh"
    minimum_tls_cipher_suite          = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    application_stack {
      python_version = 3.11
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_centralindia_tg.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_centralindia_tg.id
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_uksouth_tg.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_uksouth_tg.id
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_uksouth_devops_01.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_uksouth_devops_01.id
    }
    scm_ip_restriction {
      name                      = data.azurerm_subnet.hub_uksouth_devops_02.name
      action                    = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.hub_uksouth_devops_02.id
    }
  }

  virtual_network_subnet_id = data.azurerm_subnet.vnet_integration.id

  lifecycle {
    ignore_changes = [app_service_id]

  }
}

resource "azapi_update_resource" "main_webapp_staging_properties" {
  resource_id = azurerm_linux_web_app_slot.main_staging.id
  type        = "Microsoft.Web/sites/slots@2024-04-01"
  body = {
    properties = {
      vnetContentShareEnabled : true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main_asp" {
  name                       = local.diag_settings_name
  target_resource_id         = azurerm_service_plan.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = local.diag_settings_name
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}

resource "azurerm_monitor_diagnostic_setting" "main_staging" {
  name                       = local.diag_settings_name
  target_resource_id         = azurerm_linux_web_app_slot.main_staging.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category_group = "audit"
  }
}
