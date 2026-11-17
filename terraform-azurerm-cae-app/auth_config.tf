resource "azapi_resource" "auth_config" {
  for_each = local.auth_configs

  type      = "Microsoft.App/containerApps/authConfigs@2025-01-01"
  name      = each.value.name
  parent_id = module.container_app.container_app.id
  body = {
    properties = {
      platform = try(each.value.platform, null) == null ? null : {
        enabled        = try(each.value.platform.enabled, null)
        runtimeVersion = try(each.value.platform.runtime_version, null)
      }
      encryptionSettings = try(each.value.encryption_settings, null) == null ? {} : {
        containerAppAuthEncryptionSecretName = try(each.value.encryption_settings.container_app_auth_encryption_secret_name, null)
        containerAppAuthSigningSecretName    = try(each.value.encryption_settings.container_app_auth_signing_secret_name, null)
      }
      globalValidation = try(each.value.global_validation, null) == null ? null : {
        unauthenticatedClientAction = try(each.value.global_validation.unauthenticated_client_action, null)
        excludedPaths               = try(each.value.global_validation.exclude_paths, null)
        redirectToProvider          = try(each.value.global_validation.redirect_to_provider, null)
      }
      identityProviders = try(each.value.identity_providers, null) == null ? null : {
        azureActiveDirectory = try(each.value.identity_providers.azure_active_directory, null) == null ? null : {
          enabled = try(each.value.identity_providers.azure_active_directory.enabled, null)
          registration = try(each.value.identity_providers.azure_active_directory.registration, null) == null ? null : {
            openIdIssuer                                  = try(each.value.identity_providers.azure_active_directory.registration.open_id_issuer, null)
            clientId                                      = try(each.value.identity_providers.azure_active_directory.registration.client_id, null)
            clientSecretSettingName                       = try(each.value.identity_providers.azure_active_directory.registration.client_secret_setting_name, null)
            clientSecretCertificateThumbprint             = try(each.value.identity_providers.azure_active_directory.registration.client_secret_certificate_thumbprint, null)
            clientSecretCertificateSubjectAlternativeName = try(each.value.identity_providers.azure_active_directory.registration.client_secret_certificate_subject_alternative_name, null)
            clientSecretCertificateIssuer                 = try(each.value.identity_providers.azure_active_directory.registration.client_secret_certificate_issuer, null)
          }
          login = try(each.value.identity_providers.azure_active_directory.login, null) == null ? null : {
            loginParameters        = try(each.value.identity_providers.azure_active_directory.login.login_parameters, null)
            disableWWWAuthenticate = try(each.value.identity_providers.azure_active_directory.login.disable_www_authenticate, null)
          }
          validation = try(each.value.identity_providers.azure_active_directory.validation, null) == null ? null : {
            jwtClaimChecks = try(each.value.identity_providers.azure_active_directory.validation.jwt_claim_checks, null) == null ? null : {
              allowedGroups             = try(each.value.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_groups, null)
              allowedClientApplications = try(each.value.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_client_applications, null)
            }
            allowedAudiences = try(each.value.identity_providers.azure_active_directory.validation.allowed_audiences, null)
            defaultAuthorizationPolicy = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy, null) == null ? null : {
              allowedPrincipals = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals, null) == null ? null : {
                groups     = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.groups, null)
                identities = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.identities, null)
              }
              allowedApplications = try(each.value.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_applications, null)
            }
          }
        }
        google = try(each.value.identity_providers.google, null) == null ? null : {
          enabled = try(each.value.identity_providers.google.enabled, null)
          registration = try(each.value.identity_providers.google.registration, null) == null ? null : {
            clientId                = try(each.value.identity_providers.google.registration.client_id, null)
            clientSecretSettingName = try(each.value.identity_providers.google.registration.client_secret_setting_name, null)
          }
          login = try(each.value.identity_providers.google.login, null) == null ? null : {
            scopes = try(each.value.identity_providers.google.login.scopes, null)
          }
          validation = try(each.value.identity_providers.google.validation, null) == null ? null : {
            allowedAudiences = try(each.value.identity_providers.google.validation.allowed_audiences, null)
          }
        }
      }
      login = try(each.value.login, null) == null ? null : {
        routes = try(each.value.login.routes, null) == null ? null : {
          logoutEndpoint = try(each.value.login.routes.logout_endpoint, null)
        }
        tokenStore = try(each.value.login.token_store, null) == null ? null : {
          enabled                    = try(each.value.login.token_store.enabled, null)
          tokenRefreshExtensionHours = try(each.value.login.token_store.token_refresh_extension_hours, null)
          azureBlobStorage = try(each.value.login.token_store.azure_blob_storage, null) == null ? null : {
            sasUrlSettingName = try(each.value.login.token_store.azure_blob_storage.sas_url_setting_name, null)
          }
        }
        preserveUrlFragmentsForLogins = try(each.value.login.preserve_url_fragments_for_logins, null)
        allowedExternalRedirectUrls   = try(each.value.login.allowed_external_redirect_urls, null)
        cookieExpiration              = try(each.value.login.cookie_expiration, null)
        nonce = try(each.value.login.nonce, null) == null ? null : {
          validateNonce           = try(each.value.login.nonce.validate_nonce, null)
          nonceExpirationInterval = try(each.value.login.nonce.nonce_expiration_interval, null)
        }
      }
      httpSettings = try(each.value.http_settings, null) == null ? null : {
        requireHttps = try(each.value.http_settings.require_https, null)
        routes = try(each.value.http_settings.routes, null) == null ? null : {
          apiPrefix = try(each.value.http_settings.routes.api_prefix, null)
        }
        forwardProxy = try(each.value.http_settings.forward_proxy, null) == null ? null : {
          convention            = try(each.value.http_settings.forward_proxy.convention, null)
          customHostHeaderName  = try(each.value.http_settings.forward_proxy.custom_host_header_name, null)
          customProtoHeaderName = try(each.value.http_settings.forward_proxy.custom_proto_header_name, null)
        }
      }
    }
  }
}
