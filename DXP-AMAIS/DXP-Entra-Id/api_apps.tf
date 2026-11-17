resource "azuread_application" "main" {
  for_each = { for key, env in local.main_app_environments : key => env if key != "dev" }

  description                    = each.value.description
  device_only_auth_enabled       = local.main_app_static.device_only_auth_enabled
  display_name                   = each.value.name
  fallback_public_client_enabled = local.main_app_static.fallback_public_client_enabled
  group_membership_claims        = local.main_app_static.group_membership_claims
  oauth2_post_response_required  = local.main_app_static.oauth2_post_response_required
  owners                         = local.main_app_static.owners
  prevent_duplicate_names        = local.main_app_static.prevent_duplicate_names
  sign_in_audience               = local.main_app_static.sign_in_audience
  api {
    known_client_applications      = lookup(each.value, "known_client_applications", [])
    mapped_claims_enabled          = local.main_app_static.api.mapped_claims_enabled
    requested_access_token_version = local.main_app_static.api.requested_access_token_version
    oauth2_permission_scope {
      admin_consent_description  = local.main_app_static.api.oauth2_permission_scope.admin_consent_description
      admin_consent_display_name = local.main_app_static.api.oauth2_permission_scope.admin_consent_display_name
      enabled                    = local.main_app_static.api.oauth2_permission_scope.enabled
      id                         = local.main_app_static.api.oauth2_permission_scope.id
      type                       = local.main_app_static.api.oauth2_permission_scope.type
      value                      = local.main_app_static.api.oauth2_permission_scope.value
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
    custom_single_sign_on = local.main_app_static.feature_tags.custom_single_sign_on
    enterprise            = local.main_app_static.feature_tags.enterprise
    gallery               = local.main_app_static.feature_tags.gallery
    hide                  = local.main_app_static.feature_tags.hide
  }
  public_client {
    redirect_uris = local.main_app_static.empty_redirect_uris
  }
  required_resource_access {
    resource_app_id = local.main_app_static.required_resource_access.resource_app_id
    resource_access {
      id   = local.main_app_static.required_resource_access.resource_access.id
      type = local.main_app_static.required_resource_access.resource_access.type
    }
  }
  single_page_application {
    redirect_uris = local.main_app_static.empty_redirect_uris
  }
  web {
    homepage_url  = local.main_app_static.web.homepage_url
    logout_url    = local.main_app_static.web.logout_url
    redirect_uris = local.main_app_static.empty_redirect_uris
    implicit_grant {
      access_token_issuance_enabled = local.main_app_static.web.implicit_grant.access_token_issuance_enabled
      id_token_issuance_enabled     = local.main_app_static.web.implicit_grant.id_token_issuance_enabled
    }
  }

  lifecycle {
    ignore_changes = [identifier_uris]
  }
}

# Split from azuread_application.main so that only the dev app's SPA redirect_uris
# can be excluded from management (dev environment uses this for local testing
# redirect URIs added manually in Entra ID). lifecycle.ignore_changes cannot be
# conditional per for_each instance, hence the separate resource block.
resource "azuread_application" "main_dev" {
  for_each = { for key, env in local.main_app_environments : key => env if key == "dev" }

  description                    = each.value.description
  device_only_auth_enabled       = local.main_app_static.device_only_auth_enabled
  display_name                   = each.value.name
  fallback_public_client_enabled = local.main_app_static.fallback_public_client_enabled
  group_membership_claims        = local.main_app_static.group_membership_claims
  oauth2_post_response_required  = local.main_app_static.oauth2_post_response_required
  owners                         = []
  prevent_duplicate_names        = local.main_app_static.prevent_duplicate_names
  sign_in_audience               = local.main_app_static.sign_in_audience
  api {
    known_client_applications      = lookup(each.value, "known_client_applications", [])
    mapped_claims_enabled          = local.main_app_static.api.mapped_claims_enabled
    requested_access_token_version = local.main_app_static.api.requested_access_token_version
    oauth2_permission_scope {
      admin_consent_description  = local.main_app_static.api.oauth2_permission_scope.admin_consent_description
      admin_consent_display_name = local.main_app_static.api.oauth2_permission_scope.admin_consent_display_name
      enabled                    = local.main_app_static.api.oauth2_permission_scope.enabled
      id                         = local.main_app_static.api.oauth2_permission_scope.id
      type                       = local.main_app_static.api.oauth2_permission_scope.type
      value                      = local.main_app_static.api.oauth2_permission_scope.value
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
    custom_single_sign_on = local.main_app_static.feature_tags.custom_single_sign_on
    enterprise            = local.main_app_static.feature_tags.enterprise
    gallery               = local.main_app_static.feature_tags.gallery
    hide                  = local.main_app_static.feature_tags.hide
  }
  public_client {
    redirect_uris = local.main_app_static.empty_redirect_uris
  }
  required_resource_access {
    resource_app_id = local.main_app_static.required_resource_access.resource_app_id
    resource_access {
      id   = local.main_app_static.required_resource_access.resource_access.id
      type = local.main_app_static.required_resource_access.resource_access.type
    }
  }
  single_page_application {
    redirect_uris = local.main_app_static.empty_redirect_uris
  }
  web {
    homepage_url  = local.main_app_static.web.homepage_url
    logout_url    = local.main_app_static.web.logout_url
    redirect_uris = local.main_app_static.empty_redirect_uris
    implicit_grant {
      access_token_issuance_enabled = local.main_app_static.web.implicit_grant.access_token_issuance_enabled
      id_token_issuance_enabled     = local.main_app_static.web.implicit_grant.id_token_issuance_enabled
    }
  }

  lifecycle {
    ignore_changes = [identifier_uris, single_page_application[0].redirect_uris]
  }
}

resource "azuread_application_identifier_uri" "main" {
  for_each = local.main_app_environments

  application_id = local.main_app[each.key].id
  identifier_uri = "api://${local.main_app[each.key].client_id}"
}

resource "azuread_application_pre_authorized" "main" {
  for_each = local.main_app_environments_with_pre_authorized

  application_id       = local.main_app[each.value.environment_key].id
  authorized_client_id = each.value.app_id

  permission_ids = [
    [
      for scope in local.main_app[each.value.environment_key].api[0].oauth2_permission_scope :
      scope.id if scope.value == "access_as_user"
    ][0]
  ]
}

resource "azuread_service_principal" "main" {
  for_each = local.main_app_environments

  account_enabled              = true
  alternative_names            = []
  app_role_assignment_required = false
  client_id                    = local.main_app[each.key].client_id
  description                  = each.value.description
  notification_email_addresses = []
  owners                       = []
  feature_tags {
    custom_single_sign_on = false
    enterprise            = true
    gallery               = false
    hide                  = true
  }
}
