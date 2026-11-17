resource "azurerm_service_plan" "main" {
  count = var.use_existing_service_plan ? 0 : 1

  name                   = local.sp_name
  resource_group_name    = data.azurerm_resource_group.main.name
  location               = var.az_long_region
  os_type                = "Windows"
  sku_name               = var.service_plan_sku
  zone_balancing_enabled = var.app_instance_count > 1 || length(var.app_autoscale_rule_profiles) > 0 ? true : false
  worker_count           = length(var.app_autoscale_rule_profiles) > 0 && var.app_autoscale_rule_profiles_enabled ? null : var.app_instance_count
  tags                   = local.tags
}

module "avm-res-insights-autoscalesetting" {
  count = length(var.app_autoscale_rule_profiles) > 0 ? 1 : 0

  source              = "Azure/avm-res-insights-autoscalesetting/azurerm"
  version             = "~>0.1"
  enable_telemetry    = false
  name                = var.app_autoscale_name_override != null ? var.app_autoscale_name_override : "aspscale-${local.formatted_name}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.az_long_region
  target_resource_id  = azurerm_service_plan.main[0].id
  enabled             = var.app_autoscale_rule_profiles_enabled
  profiles            = var.app_autoscale_rule_profiles
  notification        = var.app_autoscale_rule_profiles_notification
  tags                = local.tags
}

resource "azurerm_windows_web_app" "main" {
  # TODO: Consider custom backup policy for more control?
  name                                           = local.app_name
  resource_group_name                            = data.azurerm_resource_group.main.name
  location                                       = var.az_long_region
  service_plan_id                                = var.use_existing_service_plan ? data.azurerm_service_plan.main[0].id : azurerm_service_plan.main[0].id
  client_affinity_enabled                        = var.client_affinity_enabled
  https_only                                     = true
  key_vault_reference_identity_id                = module.avm-res-managedidentity-userassignedidentity-app.resource_id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  app_settings                                   = local.production_slot_map.production.app_settings
  tags                                           = local.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.avm-res-managedidentity-userassignedidentity-app.resource_id
    ]
  }

  site_config {
    always_on                         = true
    http2_enabled                     = true
    health_check_path                 = var.health_check_enabled == true ? var.health_check_path : null
    health_check_eviction_time_in_min = var.health_check_enabled == true ? var.health_check_eviction_time_in_min : null
    ftps_state                        = "Disabled"
    scm_minimum_tls_version           = "1.2"
    use_32_bit_worker                 = false
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Deny"
    minimum_tls_cipher_suite          = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.app_stack_dotnet_version_production
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
    app_setting_names = local.app_sticky_settings_names
  }

  virtual_network_subnet_id = data.azurerm_subnet.vnet_integration.id

  dynamic "storage_account" {
    for_each = local.storage_accounts_map
    content {
      type         = storage_account.value.type
      name         = storage_account.value.name
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = data.azurerm_storage_account.main[storage_account.value.name].primary_access_key
      mount_path   = storage_account.value.mount_path
    }
  }

  lifecycle {
    ignore_changes = [site_config[0].ip_restriction]
  }

  depends_on = [time_sleep.azurerm_roles_all]
}

resource "azapi_update_resource" "main_webapp_properties" {
  resource_id = azurerm_windows_web_app.main.id
  type        = "Microsoft.Web/sites@2024-04-01"
  body = {
    properties = {
      vnetImagePullEnabled : true
      vnetContentShareEnabled : true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main_webapp" {
  name                       = local.diag_settings_name
  target_resource_id         = azurerm_windows_web_app.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category = "appserviceauditlogs"
  }
}

resource "azurerm_windows_web_app_slot" "main_staging" {
  name                                           = local.staging_slot_name
  app_service_id                                 = azurerm_windows_web_app.main.id
  client_affinity_enabled                        = var.client_affinity_enabled
  https_only                                     = true
  key_vault_reference_identity_id                = module.avm-res-managedidentity-userassignedidentity-app-staging.resource_id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  app_settings                                   = local.staging_slot_map.staging.app_settings
  tags                                           = local.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.avm-res-managedidentity-userassignedidentity-app-staging.resource_id
    ]
  }

  site_config {
    always_on                         = true
    http2_enabled                     = true
    health_check_path                 = var.health_check_enabled == true ? var.health_check_path : null
    health_check_eviction_time_in_min = var.health_check_enabled == true ? var.health_check_eviction_time_in_min : null
    ftps_state                        = "Disabled"
    scm_minimum_tls_version           = "1.2"
    use_32_bit_worker                 = false
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Deny"
    minimum_tls_cipher_suite          = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = var.app_stack_dotnet_version_staging
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

  dynamic "storage_account" {
    for_each = local.storage_accounts_map
    content {
      type         = storage_account.value.type
      name         = storage_account.value.name
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = data.azurerm_storage_account.main[storage_account.value.name].primary_access_key
      mount_path   = storage_account.value.mount_path
    }
  }

  lifecycle {
    ignore_changes = [app_service_id, site_config[0].ip_restriction]
  }

  depends_on = [time_sleep.azurerm_roles_all]
}

resource "azapi_update_resource" "main_webapp_staging_properties" {
  resource_id = azurerm_windows_web_app_slot.main_staging.id
  type        = "Microsoft.Web/sites/slots@2024-04-01"
  body = {
    properties = {
      vnetImagePullEnabled : true
      vnetContentShareEnabled : true
    }
  }
}
resource "azurerm_monitor_diagnostic_setting" "main_webapp_staging" {
  name                       = local.diag_settings_name
  target_resource_id         = azurerm_windows_web_app_slot.main_staging.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category = "appserviceauditlogs"
  }
}

resource "azurerm_windows_web_app_slot" "main_additional" {
  for_each = local.additional_slots_map

  name                                           = each.key
  app_service_id                                 = azurerm_windows_web_app.main.id
  client_affinity_enabled                        = var.client_affinity_enabled
  https_only                                     = true
  key_vault_reference_identity_id                = local.app_mi_ids[each.value.app_settings_base_slot]
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  app_settings                                   = each.value.app_settings
  tags                                           = local.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      local.app_mi_ids[each.value.app_settings_base_slot]
    ]
  }

  site_config {
    always_on                         = true
    http2_enabled                     = true
    health_check_path                 = var.health_check_enabled == true ? var.health_check_path : null
    health_check_eviction_time_in_min = var.health_check_enabled == true ? var.health_check_eviction_time_in_min : null
    ftps_state                        = "Disabled"
    scm_minimum_tls_version           = "1.2"
    use_32_bit_worker                 = false
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Deny"
    minimum_tls_cipher_suite          = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = each.value.app_stack_dotnet_version
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

  dynamic "storage_account" {
    for_each = local.storage_accounts_map
    content {
      type         = storage_account.value.type
      name         = storage_account.value.name
      account_name = storage_account.value.account_name
      share_name   = storage_account.value.share_name
      access_key   = data.azurerm_storage_account.main[storage_account.value.name].primary_access_key
      mount_path   = storage_account.value.mount_path
    }
  }

  lifecycle {
    ignore_changes = [app_service_id, site_config[0].ip_restriction]
  }

  depends_on = [time_sleep.azurerm_roles_all]
}

resource "azapi_update_resource" "main_webapp_additional_slot_properties" {
  for_each = local.additional_slots_map

  resource_id = azurerm_windows_web_app_slot.main_additional[each.key].id
  type        = "Microsoft.Web/sites/slots@2024-04-01"
  body = {
    properties = {
      vnetImagePullEnabled : true
      vnetContentShareEnabled : true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "main_webapp_additional_slot" {
  for_each = local.additional_slots_map

  name                       = local.diag_settings_name
  target_resource_id         = azurerm_windows_web_app_slot.main_additional[each.key].id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.shared.id

  enabled_log {
    category = "appserviceauditlogs"
  }
}
