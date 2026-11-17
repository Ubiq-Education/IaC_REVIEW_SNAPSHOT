# SendGrid event receiver registration (#7820)
# Contract: infra-shared tf/ubiq-sendgrid-event-receiver/API.md (admin endpoints) and SENDGRID.md (per-site webhook).
# This file is identical in terraform-azurerm-amais-site and terraform-azurerm-amais-site-legacy; change both in lock step.

locals {
  sendgrid_events_hosts = {
    prod    = "sendgrid-events.amais.com"
    staging = "sendgrid-events-staging.amais.com"
  }

  # Only slots with their own SendGrid subuser are registered; the others share the default sender and have no
  # subuser to attach a webhook to. Slot to receiver mapping is the same as for UBIQ_SHORTENER_*.
  sendgrid_events_slot_environments = {
    production = var.enable_custom_send_grid_config_production ? "prod" : null
    staging = (
      local.add_staging_slot && var.enable_custom_send_grid_config_staging ?
      (var.dev_site != "no" ? "staging" : "prod") :
      null
    )
  }
  # Receiver environments used by at least one enabled slot. On a non-dev site with both flags on, both slots share
  # the one prod registration.
  sendgrid_events_environments = toset(compact(values(local.sendgrid_events_slot_environments)))

  # Never the web app's name or the internal site name, or anything derived from either.
  sendgrid_events_site_name = one(random_id.sendgrid_events_site[*].hex)

  # Consumed ONLY by kv_ubiq_sendgrid_events_site_key_sv. Never reference this from outputs, app setting values,
  # config blobs or anything else: the site key goes only to the site Key Vault.
  sendgrid_events_site_key = {
    prod = length(restful_operation.sendgrid_events_site_prod) == 0 ? null : (
      var.sendgrid_events_site_key_rotation_increment > 0
      ? restful_operation.sendgrid_events_site_key_rotation_prod[tostring(var.sendgrid_events_site_key_rotation_increment)].sensitive_output.apiKey
      : restful_operation.sendgrid_events_site_prod[0].sensitive_output.apiKey
    )
    staging = length(restful_operation.sendgrid_events_site_staging) == 0 ? null : (
      var.sendgrid_events_site_key_rotation_increment > 0
      ? restful_operation.sendgrid_events_site_key_rotation_staging[tostring(var.sendgrid_events_site_key_rotation_increment)].sensitive_output.apiKey
      : restful_operation.sendgrid_events_site_staging[0].sensitive_output.apiKey
    )
  }
}

# 8 bytes = 16 hex characters, separate from the captcha name. Turning both SendGrid flags off destroys it, so
# turning one back on registers a new name and the subuser's Event Webhook must be reconfigured.
resource "random_id" "sendgrid_events_site" {
  count       = length(local.sendgrid_events_environments) > 0 ? 1 : 0
  byte_length = 8
}

# Replacing the register operation when the name changes deletes the old registration (its delete hook uses the old
# path) instead of leaving it behind.
resource "terraform_data" "sendgrid_events_site_name" {
  count = length(random_id.sendgrid_events_site)
  input = local.sendgrid_events_site_name
}

### Prod receiver
resource "restful_operation" "sendgrid_events_site_prod" {
  count                = contains(local.sendgrid_events_environments, "prod") ? 1 : 0
  provider             = restful.sendgrid_events_prod
  path                 = "/api/sites"
  method               = "POST"
  body                 = { siteName = local.sendgrid_events_site_name }
  use_sensitive_output = true
  # Deleting the site also deletes its retained events
  delete_method = "DELETE"
  delete_path   = "/api/sites/${local.sendgrid_events_site_name}"

  lifecycle {
    replace_triggered_by = [terraform_data.sendgrid_events_site_name[0]]
  }
}

resource "restful_operation" "sendgrid_events_site_key_rotation_prod" {
  for_each = (
    length(restful_operation.sendgrid_events_site_prod) > 0 && var.sendgrid_events_site_key_rotation_increment > 0 ?
    toset([tostring(var.sendgrid_events_site_key_rotation_increment)]) :
    toset([])
  )
  provider             = restful.sendgrid_events_prod
  path                 = "/api/sites/${local.sendgrid_events_site_name}/apikey"
  method               = "POST"
  use_sensitive_output = true
  depends_on           = [restful_operation.sendgrid_events_site_prod]

  # A rotated key belongs to one registration: after the register operation is replaced, the old rotation output
  # would otherwise stay the effective key.
  lifecycle {
    replace_triggered_by = [restful_operation.sendgrid_events_site_prod[0]]
  }
}

### Staging receiver (dev sites with custom SendGrid config on the staging slot only)
resource "restful_operation" "sendgrid_events_site_staging" {
  count                = contains(local.sendgrid_events_environments, "staging") ? 1 : 0
  provider             = restful.sendgrid_events_staging
  path                 = "/api/sites"
  method               = "POST"
  body                 = { siteName = local.sendgrid_events_site_name }
  use_sensitive_output = true
  # Deleting the site also deletes its retained events
  delete_method = "DELETE"
  delete_path   = "/api/sites/${local.sendgrid_events_site_name}"

  lifecycle {
    replace_triggered_by = [terraform_data.sendgrid_events_site_name[0]]
  }
}

resource "restful_operation" "sendgrid_events_site_key_rotation_staging" {
  for_each = (
    length(restful_operation.sendgrid_events_site_staging) > 0 && var.sendgrid_events_site_key_rotation_increment > 0 ?
    toset([tostring(var.sendgrid_events_site_key_rotation_increment)]) :
    toset([])
  )
  provider             = restful.sendgrid_events_staging
  path                 = "/api/sites/${local.sendgrid_events_site_name}/apikey"
  method               = "POST"
  use_sensitive_output = true
  depends_on           = [restful_operation.sendgrid_events_site_staging]

  lifecycle {
    replace_triggered_by = [restful_operation.sendgrid_events_site_staging[0]]
  }
}
