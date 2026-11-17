# Cap captcha service registration (#7821)
# Contract: infra-shared tf/ubiq-cap-core-bunny/API.md, "Provisioning from Terraform".
# This file is identical in terraform-azurerm-amais-site and terraform-azurerm-amais-site-legacy; change both in lock step.

locals {
  # No toggle: prod always, staging for dev sites with a staging slot (the same as the shortener)
  captcha_environments = local.shortener_environments
  captcha_hosts = {
    prod    = "captcha.amais.com"
    staging = "captcha-staging.amais.com"
  }
  captcha_assets = { for env, doc in data.http.captcha_assets : env => jsondecode(doc.response_body) }

  # Public (it is in the widget endpoint), so random: never the web app's name (its origin hostname) or the internal
  # site name, or anything derived from either.
  captcha_site_name = random_id.captcha_site.hex

  # Sorted and de-duplicated so the origins call only re-runs on a real change.
  captcha_origins = {
    # Every hostname that serves the production slot (the AZ_WEBAPP_ALL_FQDN set), plus the staging slot when it uses
    # the prod captcha service (non-dev sites).
    prod = sort(distinct(compact(concat(
      [for fqdn in distinct(concat(var.web_domains, [local.az_webapp_default_fqdn_production])) : "https://${fqdn}"],
      [local.production_url],
      local.add_staging_slot && var.dev_site == "no" ? [local.staging_url, "https://${local.az_webapp_default_fqdn_staging}"] : []
    ))))
    staging = sort(distinct(compact([local.staging_url, "https://${local.az_webapp_default_fqdn_staging}"])))
  }

  # Consumed ONLY by kv_ubiq_captcha_site_key_sv. Never reference this from outputs, app setting values, config blobs
  # or anything else: the site key goes only to the site Key Vault.
  captcha_site_key = {
    prod = length(restful_operation.captcha_site_prod) == 0 ? null : (
      var.captcha_site_key_rotation_increment > 0
      ? restful_operation.captcha_site_key_rotation_prod[tostring(var.captcha_site_key_rotation_increment)].sensitive_output.apiKey
      : restful_operation.captcha_site_prod[0].sensitive_output.apiKey
    )
    staging = length(restful_operation.captcha_site_staging) == 0 ? null : (
      var.captcha_site_key_rotation_increment > 0
      ? restful_operation.captcha_site_key_rotation_staging[tostring(var.captcha_site_key_rotation_increment)].sensitive_output.apiKey
      : restful_operation.captcha_site_staging[0].sensitive_output.apiKey
    )
  }
}

# 8 bytes = 16 hex characters: unique across sites without any prefix and stable for the life of the state.
resource "random_id" "captcha_site" {
  byte_length = 8
}

# Replacing the register operation when the name changes deletes the old registration (its delete hook uses the old
# path) instead of leaving it behind.
resource "terraform_data" "captcha_site_name" {
  input = local.captcha_site_name
}

### Prod captcha service
resource "restful_operation" "captcha_site_prod" {
  count                = contains(local.captcha_environments, "prod") ? 1 : 0
  provider             = restful.captcha_prod
  path                 = "/api/sites"
  method               = "POST"
  body                 = { siteName = local.captcha_site_name } # never add origins here
  use_sensitive_output = true
  delete_method        = "DELETE"
  delete_path          = "/api/sites/${local.captcha_site_name}"

  lifecycle {
    replace_triggered_by = [terraform_data.captcha_site_name]
  }
}

resource "restful_operation" "captcha_origins_prod" {
  count      = length(restful_operation.captcha_site_prod)
  provider   = restful.captcha_prod
  path       = "/api/sites/${local.captcha_site_name}/origins"
  method     = "POST"
  body       = { origins = local.captcha_origins.prod }
  depends_on = [restful_operation.captcha_site_prod]

  # A replaced registration starts with no origins, so the origins call must run again with it.
  lifecycle {
    replace_triggered_by = [restful_operation.captcha_site_prod[count.index]]
  }
}

resource "restful_operation" "captcha_site_key_rotation_prod" {
  for_each = (
    length(restful_operation.captcha_site_prod) > 0 && var.captcha_site_key_rotation_increment > 0 ?
    toset([tostring(var.captcha_site_key_rotation_increment)]) :
    toset([])
  )
  provider             = restful.captcha_prod
  path                 = "/api/sites/${local.captcha_site_name}/apikey"
  method               = "POST"
  use_sensitive_output = true
  depends_on           = [restful_operation.captcha_site_prod]

  # A rotated key belongs to one registration: after the register operation is replaced, the old rotation output
  # would otherwise stay the effective key.
  lifecycle {
    replace_triggered_by = [restful_operation.captcha_site_prod[0]]
  }
}

### Staging captcha service (dev sites with a staging slot only)
resource "restful_operation" "captcha_site_staging" {
  count                = contains(local.captcha_environments, "staging") ? 1 : 0
  provider             = restful.captcha_staging
  path                 = "/api/sites"
  method               = "POST"
  body                 = { siteName = local.captcha_site_name } # never add origins here
  use_sensitive_output = true
  delete_method        = "DELETE"
  delete_path          = "/api/sites/${local.captcha_site_name}"

  lifecycle {
    replace_triggered_by = [terraform_data.captcha_site_name]
  }
}

resource "restful_operation" "captcha_origins_staging" {
  count      = length(restful_operation.captcha_site_staging)
  provider   = restful.captcha_staging
  path       = "/api/sites/${local.captcha_site_name}/origins"
  method     = "POST"
  body       = { origins = local.captcha_origins.staging }
  depends_on = [restful_operation.captcha_site_staging]

  lifecycle {
    replace_triggered_by = [restful_operation.captcha_site_staging[count.index]]
  }
}

resource "restful_operation" "captcha_site_key_rotation_staging" {
  for_each = (
    length(restful_operation.captcha_site_staging) > 0 && var.captcha_site_key_rotation_increment > 0 ?
    toset([tostring(var.captcha_site_key_rotation_increment)]) :
    toset([])
  )
  provider             = restful.captcha_staging
  path                 = "/api/sites/${local.captcha_site_name}/apikey"
  method               = "POST"
  use_sensitive_output = true
  depends_on           = [restful_operation.captcha_site_staging]

  lifecycle {
    replace_triggered_by = [restful_operation.captcha_site_staging[0]]
  }
}
