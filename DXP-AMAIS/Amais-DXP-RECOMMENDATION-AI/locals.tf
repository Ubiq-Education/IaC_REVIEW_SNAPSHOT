locals {
  sub_id             = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  subnet_identifier  = element(split("-", data.azurerm_subscription.current.subscription_id), 0)
  az_long_region     = "uksouth"
  short_region       = module.short-region-lookup.short_region
  service_plan_sku   = "P0v3"
  app_name           = "Amais-DXP-RECOMMENDATION-AI"
  sp_name            = "Amais-DXP-AI-Linux"
  lower_sp_name      = lower(local.sp_name)
  formatted_name     = "${local.short_region}-${local.lower_sp_name}"
  app_zone_redundant = false
  app_instance_count = 1
  diag_settings_name = "default_diagnostic_settings"
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
  }
}
