variable "OAuthSettings__ApiKey_production" {
  type        = string
  sensitive   = true
  description = "The value for OAuthSettings__ApiKey in the production slot"
}

variable "OAuthSettings__ApiKey_staging" {
  type        = string
  sensitive   = true
  description = "The value for OAuthSettings__ApiKey in the staging slot"
}

module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Directory and SSO integration provider
  directory_and_sso_integration_provider = "Blackbaud"

  ## Blackbaud SSO
  enable_blackbaud_sso                   = true
  blackbaud_sso_auth_api_slug_production = ""
  blackbaud_sso_auth_api_slug_staging    = ""
  blackbaud_account_name                 = ""
  blackbaud_oauth_sso_api_key_production = var.OAuthSettings__ApiKey_production
  blackbaud_oauth_sso_api_key_staging    = var.OAuthSettings__ApiKey_staging

  ## Blackbaud Sync Jobs - DEPRECATED AND NOW HANDLED BY THE CMS SETTINGS
  enable_BlackbaudSynchJobSettings                  = true
  BlackbaudSynchJobSettings_slot_name               = "staging" # OPTIONAL - Default is "production"
  BlackbaudSynchJobSettings_schedule                = "0 0 4 * * ?"
  enable_BlackbaudSynchAthleticsUpdateJobSetting    = true
  BlackbaudSynchAthleticsUpdateJobSetting_slot_name = "staging" # OPTIONAL - Default is "production"
  BlackbaudSynchAthleticsUpdateJobSetting_schedule  = "0 0 11-23 * * ?"
}
