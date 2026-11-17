variable "send_grid_key_production" {
  type        = string
  sensitive   = true
  description = "The production slot SendGrid API key for custom SendGrid configuration"
}

variable "send_grid_key_staging" {
  type        = string
  sensitive   = true
  description = "The staging slot SendGrid API key for custom SendGrid configuration"
}

module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.5.0"

  # ... required settings omitted for brevity ...

  ## Email Module
  enable_email_module_production            = true
  enable_email_module_staging               = true
  EmailStatsSyncJobSettings_slot_name       = "staging" # OPTIONAL - Default is "production"
  EmailSupressionsSyncJobSettings_slot_name = "staging" # OPTIONAL - Default is "production"

  ## Custom SendGrid Configuration
  enable_custom_send_grid_config_production = true
  enable_custom_send_grid_config_staging    = true
  send_grid_key_production                  = var.send_grid_key_production
  send_grid_key_staging                     = var.send_grid_key_staging
  send_grid_email_sender                    = ""
  send_grid_marketing_unsubscribe_group_id  = ""
  send_grid_unsubscribe_groups              = ""
  send_grid_user                            = ""

  ## SendGrid Event Receiver
  # Each slot with custom SendGrid config is registered with the Ubiq SendGrid event receiver automatically and gets
  # UBIQ_SENDGRID_EVENTS_ENDPOINT and UBIQ_SENDGRID_EVENTS_SITE_KEY (a Key Vault reference). The CMS will configure the subuser's
  # Event Webhook using the site name from the deployed UBIQ_SENDGRID_EVENTS_ENDPOINT.
  sendgrid_events_site_key_rotation_increment = 0         # OPTIONAL - Increment by exactly one to rotate the site key
  ubiq_sendgrid_events_admin_key_selection    = "primary" # OPTIONAL - "primary" or "secondary"
}
