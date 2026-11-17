module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.2.0"

  # ... required settings omitted for brevity ...

  ## Form Payments
  enable_form_payments_production = true
  enable_form_payments_staging    = true
}
