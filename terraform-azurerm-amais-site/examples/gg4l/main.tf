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

variable "GG4L_SynchClientId" {
  type        = string
  sensitive   = true
  description = "The value for GG4L_SynchClientId"
}

variable "GG4L_SynchClientSecret" {
  type        = string
  sensitive   = true
  description = "The value for GG4L_SynchClientSecret"
}

module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Directory and SSO integration provider
  directory_and_sso_integration_provider = "GG4L"

  ## GG4L SSO (required alongside directory sync)
  enable_gg4l_sso                   = true
  gg4l_oauth_settings_client_id     = var.OAuthSettings__ClientId
  gg4l_oauth_settings_client_secret = var.OAuthSettings__ClientSecret

  ## GG4L Directory Sync
  enable_gg4l_directory_synch = true
  gg4l_synch_client_id        = var.GG4L_SynchClientId
  gg4l_synch_client_secret    = var.GG4L_SynchClientSecret
}
