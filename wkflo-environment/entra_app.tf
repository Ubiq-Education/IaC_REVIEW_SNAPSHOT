locals {
  main_app_roles = {
    "6f52ed17-c622-4ce6-9ab3-7f0573487af9" = {
      allowed_member_types = ["Application", "User"]
      enabled              = true
      value                = "Api.Access"
    }
  }
  entra_app_description = "${title(var.environment)} environment application for Wkflo Platform"
}

resource "azuread_application" "main" {
  description                    = local.entra_app_description
  device_only_auth_enabled       = false
  display_name                   = "Wkflo Platform ${title(var.environment)}"
  fallback_public_client_enabled = false
  group_membership_claims        = []
  oauth2_post_response_required  = false
  owners                         = []
  prevent_duplicate_names        = false
  sign_in_audience               = "AzureADMyOrg"

  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "access_as_user"
      admin_consent_display_name = "access_as_user"
      enabled                    = true
      id                         = "26349c97-9867-413c-b44d-426ff0c072cf"
      type                       = "Admin"
      value                      = "access_as_user"
    }
  }

  dynamic "app_role" {
    for_each = local.main_app_roles
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = lookup(app_role.value, "description", app_role.value.value)
      display_name         = lookup(app_role.value, "display_name", app_role.value.value)
      enabled              = app_role.value.enabled
      id                   = app_role.key
      value                = app_role.value.value
    }
  }

  feature_tags {
    custom_single_sign_on = false
    enterprise            = false
    gallery               = false
    hide                  = false
  }

  public_client {
    redirect_uris = []
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  single_page_application {
    redirect_uris = compact([
      "https://localhost/",
      var.environment == "prod" ? null : "http://localhost:32774/scalar/v1",
      var.environment == "prod" ? null : "http://localhost:32772/scalar/v1",
      var.environment == "prod" ? null : "https://localhost:32775/scalar/v1",
      var.environment == "prod" ? null : "https://localhost:32773/scalar/v1",
      var.environment == "prod" ? "https://app.wkflo.ai/" : "https://${var.environment}.app.wkflo.ai/",
      var.environment == "prod" ? "https://gateway.wkflo.ai/" : "https://${var.environment}.gateway.wkflo.ai/"
    ])
  }

  web {
    homepage_url  = null
    logout_url    = null
    redirect_uris = []
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }

  lifecycle {
    ignore_changes = [identifier_uris]
  }
}

resource "azuread_application_identifier_uri" "main" {
  application_id = azuread_application.main.id
  identifier_uri = "api://${azuread_application.main.client_id}"
}

resource "azuread_application_pre_authorized" "main" {
  for_each = var.environment != "prod" ? {
    visual_studio = "04f0c124-f2bc-4f59-8241-bf6df9866bbd"
  } : {}

  application_id       = azuread_application.main.id
  authorized_client_id = each.value

  permission_ids = [
    [
      for scope in azuread_application.main.api[0].oauth2_permission_scope :
      scope.id if scope.value == "access_as_user"
    ][0]
  ]
}

resource "azuread_service_principal" "main" {
  account_enabled              = true
  alternative_names            = []
  app_role_assignment_required = false
  client_id                    = azuread_application.main.client_id
  description                  = local.entra_app_description
  notification_email_addresses = []
  owners                       = []
  feature_tags {
    custom_single_sign_on = false
    enterprise            = true
    gallery               = false
    hide                  = true
  }
}
