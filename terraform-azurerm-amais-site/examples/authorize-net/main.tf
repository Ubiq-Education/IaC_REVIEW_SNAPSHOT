variable "authorize_net_api_login_id" {
  type        = string
  sensitive   = true
  description = "The Authorize.Net API login ID"
}

variable "authorize_net_public_client_key" {
  type        = string
  sensitive   = true
  description = "The Authorize.Net public client key"
}

variable "authorize_net_transaction_key" {
  type        = string
  sensitive   = true
  description = "The Authorize.Net transaction key"
}

module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Authorize.Net Integration
  enable_authorize_net_integration_production = true
  enable_authorize_net_integration_staging    = true
  authorize_net_api_login_id                  = var.authorize_net_api_login_id
  authorize_net_public_client_key             = var.authorize_net_public_client_key
  authorize_net_transaction_key               = var.authorize_net_transaction_key
}
