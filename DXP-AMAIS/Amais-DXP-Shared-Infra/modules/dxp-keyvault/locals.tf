locals {
  azure_tenant_id              = data.azurerm_client_config.current.tenant_id
  short_region                 = module.short-region-lookup.short_region
  diag_settings_name           = "default_diagnostic_settings"
  log_analytics_workspace_name = "log-uks-ubiq-shared-logging"
  log_analytics_workspace_rg   = "rg-uks-ubiq-shared-logging"
  lock_note                    = "This resource is locked by Terraform"
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
  }
  tags = merge(var.tags, local.common_tags)
}
