## SSO resources should always use azuread.amais provider alias
## provider = azuread.amais

resource "azuread_application" "sso_main" {
  provider                       = azuread.amais
  display_name                   = "${var.site_name} AMAIS"
  prevent_duplicate_names        = true
  device_only_auth_enabled       = false
  fallback_public_client_enabled = false
  group_membership_claims        = ["ApplicationGroup"]
  sign_in_audience               = "AzureADMyOrg"

  api {
    requested_access_token_version = 2
    mapped_claims_enabled          = true
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${var.site_name} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${var.site_name}"
      enabled                    = true
      id                         = "1a4d57f9-cb8f-4508-9ddd-f1616c102ff3"
      type                       = "User"
      user_consent_description   = "Allow the application to access ${var.site_name} on your behalf."
      user_consent_display_name  = "Access ${var.site_name}"
      value                      = "user_impersonation"
    }
  }

  web {
    redirect_uris = [for url in local.ubiq_sso_app_urls : "${replace(url, "/$", "")}/web/account/saml/${local.ubiq_sso_entity_id}"]
    homepage_url  = "${replace(local.production_url, "/$", "")}/ubiqlogin"
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  optional_claims {
    saml2_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
  }

  lifecycle {
    # Add identifier uri later after the SPN has configured the SSO mode
    ignore_changes = [identifier_uris]
  }
}

resource "azuread_service_principal" "sso_main" {
  provider                      = azuread.amais
  client_id                     = azuread_application.sso_main.client_id
  account_enabled               = true
  app_role_assignment_required  = true
  notification_email_addresses  = ["<REDACTED>"]
  preferred_single_sign_on_mode = "saml"

  saml_single_sign_on {
    relay_state = "/admin"
  }

  feature_tags {
    custom_single_sign_on = true
    enterprise            = true
    gallery               = false
    hide                  = true
  }
}

# Set the Identifier URI after the SPN SSO mode is set to saml to ensure the format is accepted
# https://learn.microsoft.com/en-us/entra/identity-platform/identifier-uri-restrictions#policy-behavior
resource "azuread_application_identifier_uri" "sso_main" {
  provider       = azuread.amais
  application_id = azuread_application.sso_main.id
  identifier_uri = local.ubiq_sso_entity_id

  depends_on = [azuread_service_principal.sso_main]
}

# Map the AMAIS SSO claims mapping policy to correctly populate the Google email in the SAML token
resource "azuread_service_principal_claims_mapping_policy_assignment" "sso_main" {
  provider                 = azuread.amais
  claims_mapping_policy_id = "/policies/claimsMappingPolicies/0bb37b16-ea04-437c-ad32-48d77975a331" # No data source for this yet
  service_principal_id     = azuread_service_principal.sso_main.id
}

## Enter cert rotation management madness...
# Rotate each cert based initial creation date staggered by 6 months, first common multiplier / rotation date is 22 years
resource "time_rotating" "sso_cert_1" {
  rotation_days = 730 # 2 years

  depends_on = [azuread_service_principal.sso_main]
}

resource "time_rotating" "sso_cert_2" {
  rotation_days = 990 # 2 years 9 months

  depends_on = [azuread_service_principal.sso_main]
}

# Create 3 year offset for each cert end dates as max supported by Entra ID
resource "time_offset" "sso_cert_1" {
  offset_days  = 1094
  base_rfc3339 = time_rotating.sso_cert_1.rfc3339
}

resource "time_offset" "sso_cert_2" {
  offset_days  = 1094
  base_rfc3339 = time_rotating.sso_cert_2.rfc3339
}

# Create 2 token signing certificates for safe rotation
resource "azuread_service_principal_token_signing_certificate" "sso_main_1" {
  provider             = azuread.amais
  service_principal_id = azuread_service_principal.sso_main.id
  end_date             = time_offset.sso_cert_1.rfc3339
  lifecycle {
    replace_triggered_by = [time_rotating.sso_cert_1.rfc3339]
  }
}

resource "azuread_service_principal_token_signing_certificate" "sso_main_2" {
  provider             = azuread.amais
  service_principal_id = azuread_service_principal.sso_main.id
  end_date             = time_offset.sso_cert_2.rfc3339
  lifecycle {
    replace_triggered_by = [time_rotating.sso_cert_2.rfc3339]
  }
}

resource "azuread_app_role_assignment" "sso_main_all_ubiq_guests" {
  provider            = azuread.amais
  app_role_id         = "00000000-0000-0000-0000-000000000000" # Default User Role
  principal_object_id = "b760d089-c4ab-4a4c-b3a0-b095cbaae470" # All Ubiq Colleagues group
  resource_object_id  = azuread_service_principal.sso_main.object_id
}
