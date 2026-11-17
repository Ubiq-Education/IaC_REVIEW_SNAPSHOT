module "amais_site" {
  source  = "api.controlmonkey.io/o-26drsisx9g/amais-site/azurerm"
  version = "~>2.5.0"

  # ... required settings omitted for brevity ...

  ## Cap Captcha Service
  # Every site is registered with the Ubiq captcha service automatically (prod, plus staging for dev sites with a
  # staging slot); there is no toggle. Both slots get the UBIQ_CAPTCHA_* app settings, with the site key as a Key Vault
  # reference. The settings below are only needed to rotate the site key or switch the admin key.
  captcha_site_key_rotation_increment = 0         # OPTIONAL - Increment by exactly one to rotate the site key; never decrease
  ubiq_captcha_admin_key_selection    = "primary" # OPTIONAL - "primary" or "secondary"
}
