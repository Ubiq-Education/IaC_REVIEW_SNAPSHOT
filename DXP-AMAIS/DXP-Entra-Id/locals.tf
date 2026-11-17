locals {
  entra_groups = {
    azure_rbac_dxp_platform_staging_all = "eb1a7c61-67c5-4950-a30a-918e4f3ba9e0"
  }
  main_app_environments = {
    dev = {
      name        = "DXP Platform Dev"
      description = "Development environment"
      pre_authorized_applications = [
        "04f0c124-f2bc-4f59-8241-bf6df9866bbd", # Visual Studio
        "04b07795-8ddb-461a-bbee-02f9e1bf7b46", # Azure CLI
        "1950a258-227b-4e31-a9cf-717495945fc2", # Azure PowerShell
      ]
    }
    staging = {
      name        = "DXP Platform Staging"
      description = "Staging environment"
      pre_authorized_applications = [
        "04f0c124-f2bc-4f59-8241-bf6df9866bbd", # Visual Studio
      ]
    }
    prod = {
      name        = "DXP Platform"
      description = "Production environment"
    }
  }
  # Static configuration shared by azuread_application.main and azuread_application.main_dev.
  # Kept in one place so the two resource blocks can't drift from each other over time.
  main_app_static = {
    device_only_auth_enabled       = false
    fallback_public_client_enabled = false
    group_membership_claims        = []
    oauth2_post_response_required  = false
    owners                         = []
    prevent_duplicate_names        = false
    sign_in_audience               = "AzureADMyOrg"
    empty_redirect_uris            = []

    api = {
      mapped_claims_enabled          = false
      requested_access_token_version = 1
      oauth2_permission_scope = {
        admin_consent_description  = "access_as_user"
        admin_consent_display_name = "access_as_user"
        enabled                    = true
        id                         = "26349c97-9867-413c-b44d-426ff0c072cf"
        type                       = "Admin"
        value                      = "access_as_user"
      }
    }

    feature_tags = {
      custom_single_sign_on = false
      enterprise            = false
      gallery               = false
      hide                  = false
    }

    required_resource_access = {
      resource_app_id = "00000003-0000-0000-c000-000000000000"
      resource_access = {
        id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
        type = "Scope"
      }
    }

    web = {
      homepage_url = null
      logout_url   = null
      implicit_grant = {
        access_token_issuance_enabled = false
        id_token_issuance_enabled     = false
      }
    }
  }

  main_app_environments_with_pre_authorized = merge([
    for env_key, env in local.main_app_environments :
    {
      for app_id in try(env.pre_authorized_applications, []) :
      "${env_key}_${app_id}" => {
        environment_key = env_key
        app_id          = app_id
      }
    }
  ]...)
  sub_id    = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  az_region = "uksouth"
  common_tags = {
    environment       = "prod"
    deployment_method = "terraform"
  }
  dev_tags = {
    environment       = "dev"
    deployment_method = "terraform"
  }
  # Combines azuread_application.main and azuread_application.main_dev (split out so
  # that only the dev app's SPA redirect_uris can have ignore_changes applied) back
  # into a single lookup keyed the same way as local.main_app_environments.
  main_app = merge(azuread_application.main, azuread_application.main_dev)

  all_main_app_roles = merge([
    for key, app in local.main_app : {
      for role_id, role in local.main_app_roles :
      "${key}_${role_id}" => {
        app_role_id = role_id
        app_key     = key
      }
    }
  ]...)
}
