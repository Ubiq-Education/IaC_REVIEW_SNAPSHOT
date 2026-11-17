terraform {
  required_version = "~>1.9"

  backend "azurerm" {
    use_azuread_auth     = true
    subscription_id      = "a3236c88-aba1-449e-879a-272e0c2ac067"
    storage_account_name = "sttfstatestorage01"
    container_name       = "ubiq-main"
    key                  = "site-#{variables.site_name_lower}#.tfstate" # Must match the convention used by scripts\New-AMAISSiteConfig.ps1
  }
}

module "amais_site" {
  source                                   = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version                                  = "~>2.5.1"
  syslog_token                             = var.syslog_token
  azuread_amais_client_id                  = var.azuread_amais_client_id
  azuread_amais_client_secret              = var.azuread_amais_client_secret
  azuread_amais_tenant_id                  = var.azuread_amais_tenant_id
  site_name                                = "#{variables.site_name}#"
  launch_date                              = "#{variables.launch_date_placeholder}#"
  sub_id                                   = "#{variables.sub_id}#"
  az_long_region                           = "#{variables.az_long_region}#"
  sqldb_sku                                = "S0"
  sqldb_max_size_gb                        = 50
  service_plan_sku                         = "P0v3"
  web_app_os                               = "Linux"
  amais_response_time_alert_enabled        = false
  amais_server_errors_alert_enabled        = false
  amais_health_check_alert_enabled         = false
  scheduler_manager_slot_name              = "production"
  enable_page_data_generation_job_slot     = "production"
  page_data_generation_job_cron_expression = "0 0 0 ? * *"
  enable_dxp_integration_production        = true
  web_domains                              = var.web_domains
  provision_from_baseline                  = #{variables.provision_from_baseline}#
}

output "amais_site" {
  value = module.amais_site
}
