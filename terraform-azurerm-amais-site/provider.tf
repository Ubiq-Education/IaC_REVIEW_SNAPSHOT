provider "azurerm" {
  subscription_id     = var.sub_id
  storage_use_azuread = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias               = "shared"
  subscription_id     = local.shared_sub_id
  storage_use_azuread = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azuread" {
  alias         = "amais"
  client_id     = var.azuread_amais_client_id
  client_secret = var.azuread_amais_client_secret
  tenant_id     = var.azuread_amais_tenant_id
}

provider "azureactions" {
  organization_url = "https://dev.azure.com/PetraCMS"
}

# 2026-08-28
# Bunny doesn't yet have first-party Terraform support for Shield's verified bot categorization, so this drives the
# raw REST API for that feature only; all actions are PUT (there is no delete, clearing an override is itself a PUT).
provider "restful" {
  alias = "bunny_shield"

  base_url = "https://api.bunny.net"

  header = {
    Accept       = "application/json"
    Content-Type = "application/json"
  }

  security = {
    apikey = [{
      name  = "AccessKey"
      in    = "header"
      value = try(data.azurerm_key_vault_secret.bunnynet_api_key[0].value, "")
    }]
  }
}

# The admin keys are used only in these security blocks, never in a resource header: changing a resource argument
# re-runs the operation, while a provider configuration change does not. They must never reach anything the CMS
# site can read. Providers cannot for_each, so there is one alias per environment.
provider "restful" {
  alias = "captcha_prod"

  base_url = "https://${local.captcha_hosts.prod}"

  header = {
    Accept       = "application/json"
    Content-Type = "application/json"
  }

  security = {
    apikey = [{
      name  = "X-Api-Key"
      in    = "header"
      value = try(data.azurerm_key_vault_secret.ubiq_captcha_admin_key["prod"].value, "")
    }]
  }
}

provider "restful" {
  alias = "captcha_staging"

  base_url = "https://${local.captcha_hosts.staging}"

  header = {
    Accept       = "application/json"
    Content-Type = "application/json"
  }

  security = {
    apikey = [{
      name  = "X-Api-Key"
      in    = "header"
      value = try(data.azurerm_key_vault_secret.ubiq_captcha_admin_key["staging"].value, "")
    }]
  }
}

provider "restful" {
  alias = "sendgrid_events_prod"

  base_url = "https://${local.sendgrid_events_hosts.prod}"

  header = {
    Accept       = "application/json"
    Content-Type = "application/json"
  }

  security = {
    apikey = [{
      name  = "X-Api-Key"
      in    = "header"
      value = try(data.azurerm_key_vault_secret.ubiq_sendgrid_events_admin_key["prod"].value, "")
    }]
  }
}

provider "restful" {
  alias = "sendgrid_events_staging"

  base_url = "https://${local.sendgrid_events_hosts.staging}"

  header = {
    Accept       = "application/json"
    Content-Type = "application/json"
  }

  security = {
    apikey = [{
      name  = "X-Api-Key"
      in    = "header"
      value = try(data.azurerm_key_vault_secret.ubiq_sendgrid_events_admin_key["staging"].value, "")
    }]
  }
}
