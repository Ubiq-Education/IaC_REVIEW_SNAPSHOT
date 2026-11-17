variable "OAuthSettings__ClientId" {
  type        = string
  sensitive   = true
  description = "The value for OAuthSettings__ClientId"
}

variable "OAuthSettings__ClientSecret" {
  type        = string
  sensitive   = true
  description = "The value for OAuthSettings__ClientSecret"
}

module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Directory and SSO integration provider
  directory_and_sso_integration_provider = "Veracross"

  ## Veracross SSO
  veracross_account_name                 = ""
  enable_veracross_sso                   = true
  veracross_oauth_settings_scope         = ""
  veracross_oauth_settings_client_id     = var.OAuthSettings__ClientId
  veracross_oauth_settings_client_secret = var.OAuthSettings__ClientSecret

  ## Veracross Sync Job
  enable_VeracrossSynchJobSettings             = true
  VeracrossSynchJobSettings_slot_name          = "staging" # OPTIONAL - Default is "production"
  veracross_synch_job_schedule_cron_expression = "0 0 4 * * ?"
}
