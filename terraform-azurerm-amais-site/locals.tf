locals {
  azure_tenant_id        = data.azurerm_client_config.current.tenant_id
  shared_sub_id          = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  subnet_identifier      = element(split("-", data.azurerm_subscription.current.subscription_id), 0)
  short_region           = module.short-region-lookup.short_region
  az_region_details      = module.regions.regions_by_name_or_display_name[var.az_long_region]
  az_region_zones        = length(coalesce(local.az_region_details.zones, [])) > 0 ? length(local.az_region_details.zones) : 0
  region_geography       = local.az_region_details.geography_group
  lower_site_name        = lower(var.site_name)
  formatted_name         = "${local.short_region}-${local.lower_site_name}"
  amais_application_name = var.amais_application_name != null ? var.amais_application_name : var.site_name
  templates_folder       = var.templates_folder_override != null ? var.templates_folder_override : var.site_name

  # Derived resource names
  kv_name                     = length(local.formatted_name) > 21 ? "kv-${substr(local.formatted_name, 0, 16)}-${lower(substr(random_id.main.hex, 0, 4))}" : "kv-${local.formatted_name}"
  st_name                     = "st${lower(substr(random_id.main.hex, 0, 22))}"
  sql_name                    = "sql-${local.formatted_name}"
  sql_admin_login_secret_name = "${local.sql_name}--${var.sql_admin_login}-secret"
  sqldb_name                  = "sqldb-${local.formatted_name}"
  asp_name                    = "asp-${local.formatted_name}"
  app_name                    = "app-${local.formatted_name}"
  app_mi_name                 = "id-app-${local.formatted_name}"
  staging_slot_name           = "staging"
  shortener_environments      = toset(concat(["prod"], local.add_staging_slot && var.dev_site != "no" ? ["staging"] : []))


  # AI chatbot / AI search integration
  ai_chatbot_required = var.enable_ai_chatbot_production || var.enable_ai_chatbot_staging ? true : false
  token_api_service_settings = {
    prod = {
      token_service_api_url = "https://amais-jwt-service-prod.amais.com"
      app_id_uri            = "api://89201452-c871-40dc-97e4-cee1ad4a4b30"
    }
    staging = {
      token_service_api_url = "https://amais-jwt-service-staging.amais.com"
      app_id_uri            = "api://961b1a26-ca84-4613-843e-a9a1f2f58051"
    }
  }
  ai_chatbot_function_app = {
    prod = {
      sub_id        = local.shared_sub_id
      app_name      = "func-uks-ubiq-chatbot-train-01"
      app_baseurl   = "https://func-uks-ubiq-chatbot-train-01.azurewebsites.net"
      app_rg        = "rg-uks-ai-central"
      function_name = "process_site_http"
    }
    # Use production values for staging for testing CMS updates against central resources before swapping to production
    staging = {
      sub_id        = local.shared_sub_id
      app_name      = "func-uks-ubiq-chatbot-train-01-staging"
      app_baseurl   = "https://func-uks-ubiq-chatbot-train-01-staging.azurewebsites.net"
      app_rg        = "rg-uks-ai-central"
      function_name = "process_site_http"
    }
  }
  ai_chatbot_api = {
    prod = {
      url = "https://amais-chatbot-api-prod.amais.com"
    }
    staging = {
      url = "https://amais-chatbot-api-staging.amais.com"
    }
  }
  ai_search_endpoint = "https://srch-uks-ai-central-01.search.windows.net"
  ai_search_index_names = {
    # Staging index currently not used
    staging    = "index-${lower(local.amais_application_name)}"
    production = "index-${lower(local.amais_application_name)}"
  }

  # Static website file definitions
  staticweb_files = {
    index = {
      name = "index.html"
      type = "text/html"
    }
    error = {
      name = "error.html"
      type = "text/html"
    }
    style = {
      name = "style.css"
      type = "text/css"
    }
  }

  # Web app production & staging URLs
  central_amais_sqldb_initial_catalog = "AmaisUsers"
  production_webapp_url               = "https://${local.app_name}.azurewebsites.net"
  production_webapp_url_expanded      = regex("^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?", local.production_webapp_url)
  staging_webapp_url                  = "https://${local.app_name}-${local.staging_slot_name}.azurewebsites.net"
  staging_webapp_url_expanded         = regex("^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?", local.staging_webapp_url)
  production_url = (
    var.bunny_cdn_enablement == "yes" && var.web_app_x_azure_fdid_lockdown ?
    "https://${azurerm_dns_cname_record.cdn_root[0].name}.${data.azurerm_dns_zone.website_amais_com.name}" :
    local.production_webapp_url
  )
  staging_url = local.add_staging_slot ? (
    var.bunny_cdn_enablement == "yes" && var.web_app_x_azure_fdid_lockdown ?
    "https://${azurerm_dns_cname_record.cdn_staging[0].name}.${data.azurerm_dns_zone.website_amais_com.name}" :
    local.staging_webapp_url
  ) : ""
  az_webapp_default_fqdn_production = (
    var.bunny_cdn_enablement == "yes" ?
    trimsuffix(azurerm_dns_cname_record.cdn_root[0].fqdn, ".") :
    local.production_webapp_url_expanded["authority"]
  )
  az_webapp_default_fqdn_staging = (
    var.bunny_cdn_enablement == "yes" && local.add_staging_slot ?
    trimsuffix(azurerm_dns_cname_record.cdn_staging[0].fqdn, ".") :
    local.staging_webapp_url_expanded["authority"]
  )

  # SSO / domain related
  ubiq_sso_app_urls = distinct(compact(concat(
    [local.production_url, local.production_webapp_url],
    (local.add_staging_slot ? [local.staging_url, local.staging_webapp_url] : []),
    [for domain in var.web_domains : "https://${domain}"]
  )))
  ubiq_sso_entity_id = "UbiqAMAIS-${uuidv5("url", "https://${local.lower_site_name}.${data.azurerm_dns_zone.website_amais_com.name}")}"
  ## sitename.website.amais.com and sitename.amais.com (legacy) should NOT added to prevent_cms_users_authentication_csv_domains_value to ensure admin login works through bunny but not weglot
  prevent_cms_users_authentication_csv_domains_value = join(",", distinct(concat(var.web_domains)))

  # Bunny CDN / pull zone
  x_azure_fdid_value = uuidv5("url", local.production_webapp_url)
  cdn_provider = (
    ## Update this logic if we add support for other CDN providers
    var.bunny_cdn_enablement == "yes" ? "Bunny" : "None"
  )
  # bunny_pullzone_name should be var.bunny_pullzone_config.pullzone_name if it's supplied and not empty, otherwise "pz-${local.formatted_name}-${lower(substr(random_id.main.hex, 0, 4))}"
  bunny_pullzone_name = try(var.bunny_pullzone_config.pullzone_name, null) != null ? var.bunny_pullzone_config.pullzone_name : "pz-${local.formatted_name}-${lower(substr(random_id.main.hex, 0, 4))}"
  # For selecting only the first rule if using the Basic tier for Bunny Shield
  first_additional_rate_limit_key = length(keys(var.bunny_pullzone_additional_rate_limit_rules)) > 0 ? keys(var.bunny_pullzone_additional_rate_limit_rules)[0] : null
  ams_cdn_path                    = "https://${trimsuffix(azurerm_dns_cname_record.cdn_ams.fqdn, ".")}/"
  ## Contsruct the root CDN path to avoid cyclic dependency between the web app and the pullzone
  root_cdn_path_name = "${local.lower_site_name}-cdn"
  root_cdn_path = (
    var.bunny_cdn_enablement == "yes" ?
    var.web_app_x_azure_fdid_lockdown ?
    "/cdn" :
    "https://${local.root_cdn_path_name}.${data.azurerm_dns_zone.website_amais_com.name}" :
    "/cdn"
  )

  # Redis
  amais_dxp_staging_redis_connection_string_key_name    = "amais-dxp-staging-redis-connection-string"
  amais_dxp_production_redis_connection_string_key_name = "amais-dxp-production-redis-connection-string"
  redis_connection_string = (
    contains(local.az_us_geography, lower(local.region_geography))
    ? data.azurerm_redis_cache.eus[0].primary_connection_string
    : data.azurerm_redis_cache.uks[0].primary_connection_string
  )

  # Stripe
  stripe_region_key_names = (
    contains(local.az_us_geography, lower(local.region_geography))
    ? {
      api_key = {
        production = "StripeAPIKey-Production-US"
        test       = "StripeAPIKey-Test-US"
      }
      public_key = {
        production = "StripePublicKey-Production-US"
        test       = "StripePublicKey-Test-US"
      }
    }
    : {
      api_key = {
        production = "StripeAPIKey-Production"
        test       = "StripeAPIKey-Test"
      }
      public_key = {
        production = "StripePublicKey-Production"
        test       = "StripePublicKey-Test"
      }
    }
  )

  # SendGrid
  send_grid_email_sender = "<REDACTED>"
  send_grid_user         = "<REDACTED>"

  # Storage
  blob_storage_root_container = (element(
    split("/", module.avm-res-storage-storageaccount.containers.main_priv.id),
    length(
      split("/", module.avm-res-storage-storageaccount.containers.main_priv.id)
    ) - 1
  ))

  # SQL connection strings
  db_connection_string = join("", [
    "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;",
    "Initial Catalog=${azurerm_mssql_database.main.name};",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=True;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  db_user_connection_string = join("", [
    "Server=tcp:${data.azurerm_mssql_server.central_amais.fully_qualified_domain_name},1433;",
    "Initial Catalog=${local.central_amais_sqldb_initial_catalog};",
    "Authentication=Active Directory Default;",
    "User ID=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=False;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  nlog_db_connection_string = join("", [
    "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;",
    "Initial Catalog=${azurerm_mssql_database.main.name};",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=True;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])
  nlog_db_connection_string_staging = join("", [
    "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;",
    "Initial Catalog=${azurerm_mssql_database.main.name};",
    "Authentication=Active Directory Default;",
    "User Id=${module.avm-res-managedidentity-userassignedidentity-app.resource.client_id};",
    "MultipleActiveResultSets=True;",
    "Encrypt=True;",
    "TrustServerCertificate=False;",
    "Connection Timeout=30;"
  ])

  # Service plan / staging slot capability flags
  is_sp_premium      = can(regex("^P", var.service_plan_sku))
  add_staging_slot   = var.create_staging_slot && local.is_sp_premium
  app_zone_redundant = var.enable_zone_redundant_app_service && local.az_region_zones != 0 && local.is_sp_premium

  # Identify which web app resource details to use in references based on the OS selection
  web_app_resource_id               = var.web_app_os == "Linux" ? azurerm_linux_web_app.main[0].id : azurerm_windows_web_app.main[0].id
  web_app_default_hostname          = var.web_app_os == "Linux" ? azurerm_linux_web_app.main[0].default_hostname : azurerm_windows_web_app.main[0].default_hostname
  web_app_staging_slot_ids          = var.web_app_os == "Linux" ? azurerm_linux_web_app_slot.main_staging[*].id : azurerm_windows_web_app_slot.main_staging[*].id
  web_app_staging_default_hostnames = var.web_app_os == "Linux" ? azurerm_linux_web_app_slot.main_staging[*].default_hostname : azurerm_windows_web_app_slot.main_staging[*].default_hostname

  # Default to 2 instances if not valid - 2 is the new minimum for zone redundancy from May 2025
  is_app_instance_count_valid = var.app_instance_count != null ? var.app_instance_count >= 2 : false
  app_instance_count          = local.is_app_instance_count_valid ? var.app_instance_count : 2

  # Directory and SSO integration
  enable_blackbaud_integration = var.directory_and_sso_integration_provider == "Blackbaud" ? true : false
  enable_veracross_integration = var.directory_and_sso_integration_provider == "Veracross" ? true : false
  enable_gg4l_integration      = var.directory_and_sso_integration_provider == "GG4L" ? true : false

  # Custom secret names
  site_staging_dxp_api_key_name = (
    var.amais_application_name != null ? "${var.amais_application_name}-staging-dxp-api-key" : "${var.site_name}-staging-dxp-api-key"
  )
  site_production_dxp_api_key_name = (
    var.amais_application_name != null ? "${var.amais_application_name}-production-dxp-api-key" : "${var.site_name}-production-dxp-api-key"
  )
  authorize_net_api_login_id_key_name              = "${var.site_name}-authorize-net-api-login-id"
  authorize_net_public_client_key_key_name         = "${var.site_name}-authorize-net-public-client-key"
  authorize_net_transaction_key_key_name           = "${var.site_name}-authorize-net-transaction-key"
  custom_send_grid_key_prod_key_name               = "${var.site_name}-send-grid-key-production"
  custom_send_grid_key_staging_key_name            = "${var.site_name}-send-grid-key-staging"
  blackbaud_oauth_settings_apikey_prod_key_name    = "${var.site_name}-blackbaud-oauth-settings-apikey-production"
  blackbaud_oauth_settings_apikey_staging_key_name = "${var.site_name}-blackbaud-oauth-settings-apikey-staging"
  veracross_oauth_settings_client_id_key_name      = "${var.site_name}-veracross-oauth-settings-client-id-key"
  veracross_oauth_settings_client_secret_key_name  = "${var.site_name}-veracross-oauth-settings-client-secret-key"
  gg4l_oauth_settings_client_id_key_name           = "${var.site_name}-gg4l-oauth-settings-client-id-key"
  gg4l_oauth_settings_client_secret_key_name       = "${var.site_name}-gg4l-oauth-settings-client-secret-key"
  gg4l_synch_client_id_key_name                    = "${var.site_name}-gg4l-synch-client-id-key"
  gg4l_synch_client_secret_key_name                = "${var.site_name}-gg4l-synch-client-secret-key"

  # Key vault secret keys
  kv_authorize_net_sk = var.enable_authorize_net_integration_production || var.enable_authorize_net_integration_staging ? {
    authorize_net_api_login_id = {
      name = local.authorize_net_api_login_id_key_name
      tags = merge(var.tags, local.common_tags)
    }
    authorize_net_public_client_key = {
      name = local.authorize_net_public_client_key_key_name
      tags = merge(var.tags, local.common_tags)
    }
    authorize_net_transaction_key = {
      name = local.authorize_net_transaction_key_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_custom_send_grid_key_prod_sk = var.enable_custom_send_grid_config_production ? {
    custom_send_grid_key_prod = {
      name = local.custom_send_grid_key_prod_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_custom_send_grid_key_staging_sk = var.enable_custom_send_grid_config_staging ? {
    custom_send_grid_key_staging = {
      name = local.custom_send_grid_key_staging_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_blackbaud_sk = {
    oauth_blackbaud_client_id = {
      name = data.azurerm_key_vault_secret.oauth_blackbaud_client_id.name
      tags = merge(var.tags, local.common_tags)
    }
    oauth_blackbaud_client_secret = {
      name = data.azurerm_key_vault_secret.oauth_blackbaud_client_secret.name
      tags = merge(var.tags, local.common_tags)
    }
    oauth_blackbaud_subscription_key = {
      name = data.azurerm_key_vault_secret.oauth_blackbaud_subscription_key.name
      tags = merge(var.tags, local.common_tags)
    }
  }
  kv_blackbaud_oauth_settings_apikey_sk = local.enable_blackbaud_integration && var.enable_blackbaud_sso ? {
    blackbaud_oauth_settings_apikey_prod = {
      name = local.blackbaud_oauth_settings_apikey_prod_key_name
      tags = merge(var.tags, local.common_tags)
    }
    blackbaud_oauth_settings_apikey_staging = {
      name = local.blackbaud_oauth_settings_apikey_staging_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_veracross_sk = local.enable_veracross_integration ? {
    veracross_oauth_settings_client_id = {
      name = local.veracross_oauth_settings_client_id_key_name
      tags = merge(var.tags, local.common_tags)
    }
    veracross_oauth_settings_client_secret = {
      name = local.veracross_oauth_settings_client_secret_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_gg4l_sk = var.enable_gg4l_sso ? {
    gg4l_oauth_settings_client_id = {
      name = local.gg4l_oauth_settings_client_id_key_name
      tags = merge(var.tags, local.common_tags)
    }
    gg4l_oauth_settings_client_secret = {
      name = local.gg4l_oauth_settings_client_secret_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_gg4l_directory_synch_sk = var.enable_gg4l_directory_synch ? {
    gg4l_synch_client_id = {
      name = local.gg4l_synch_client_id_key_name
      tags = merge(var.tags, local.common_tags)
    }
    gg4l_synch_client_secret = {
      name = local.gg4l_synch_client_secret_key_name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  dxp_auth0_client_staging_sk = var.enable_entra_dxp_client_staging == false ? {
    amais_dxp_staging_masterdataclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_masterdataclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_reportclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_reportclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_ingressclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_ingressclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_aiclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_staging_aiclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  dxp_auth0_client_production_sk = var.enable_entra_dxp_client_production == false ? {
    amais_dxp_production_masterdataclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_masterdataclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_reportclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_reportclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_ingressclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_ingressclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_aiclientoauthsettings_clientsecret = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientsecret[0].name
      tags = merge(var.tags, local.common_tags)
    }
    amais_dxp_production_aiclientoauthsettings_clientid = {
      name = data.azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientid[0].name
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_bunnynet_api_key_sk = var.bunny_cdn_enablement != "no" ? {
    bunnynet_api_key = {
      name = "bunnynet-api-key"
      tags = merge(var.tags, local.common_tags)
    }
  } : {}
  kv_ubiq_shortener_api_key_sk = {
    for env in local.shortener_environments : "ubiq_shortener_${env}_api_key" => {
      name = "ubiq-shortener-${env}-api-key"
      tags = merge(var.tags, local.common_tags)
    }
  }
  kv_ubiq_captcha_site_key_sk = {
    for env in local.captcha_environments : "ubiq_captcha_${env}_site_key" => {
      name = "ubiq-captcha-${env}-site-key"
      tags = merge(var.tags, local.common_tags)
    }
  }
  kv_ubiq_sendgrid_events_site_key_sk = {
    for env in local.sendgrid_events_environments : "ubiq_sendgrid_events_${env}_site_key" => {
      name = "ubiq-sendgrid-events-${env}-site-key"
      tags = merge(var.tags, local.common_tags)
    }
  }

  # Key vault secret values
  kv_authorize_net_sv = var.enable_authorize_net_integration_production || var.enable_authorize_net_integration_staging ? {
    authorize_net_api_login_id      = var.authorize_net_api_login_id
    authorize_net_public_client_key = var.authorize_net_public_client_key
    authorize_net_transaction_key   = var.authorize_net_transaction_key
  } : {}
  kv_custom_send_grid_key_prod_sv = var.enable_custom_send_grid_config_production ? {
    custom_send_grid_key_prod = var.send_grid_key_production
  } : {}
  kv_custom_send_grid_key_staging_sv = var.enable_custom_send_grid_config_staging ? {
    custom_send_grid_key_staging = var.send_grid_key_staging
  } : {}
  kv_blackbaud_sv = {
    oauth_blackbaud_client_id        = data.azurerm_key_vault_secret.oauth_blackbaud_client_id.value
    oauth_blackbaud_client_secret    = data.azurerm_key_vault_secret.oauth_blackbaud_client_secret.value
    oauth_blackbaud_subscription_key = data.azurerm_key_vault_secret.oauth_blackbaud_subscription_key.value
  }
  kv_blackbaud_oauth_settings_apikey_sv = local.enable_blackbaud_integration && var.enable_blackbaud_sso ? {
    blackbaud_oauth_settings_apikey_prod    = var.blackbaud_oauth_sso_api_key_production
    blackbaud_oauth_settings_apikey_staging = var.blackbaud_oauth_sso_api_key_staging
  } : {}
  kv_veracross_sv = local.enable_veracross_integration ? {
    veracross_oauth_settings_client_id     = var.veracross_oauth_settings_client_id
    veracross_oauth_settings_client_secret = var.veracross_oauth_settings_client_secret
  } : {}
  kv_gg4l_sv = var.enable_gg4l_sso ? {
    gg4l_oauth_settings_client_id     = var.gg4l_oauth_settings_client_id
    gg4l_oauth_settings_client_secret = var.gg4l_oauth_settings_client_secret
  } : {}
  kv_gg4l_directory_synch_sv = var.enable_gg4l_directory_synch ? {
    gg4l_synch_client_id     = var.gg4l_synch_client_id
    gg4l_synch_client_secret = var.gg4l_synch_client_secret
  } : {}
  dxp_auth0_client_staging_sv = var.enable_entra_dxp_client_staging == false ? {
    amais_dxp_staging_masterdataclientoauthsettings_clientsecret = data.azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientsecret[0].value
    amais_dxp_staging_masterdataclientoauthsettings_clientid     = data.azurerm_key_vault_secret.amais_dxp_staging_masterdataclientoauthsettings_clientid[0].value
    amais_dxp_staging_reportclientoauthsettings_clientsecret     = data.azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientsecret[0].value
    amais_dxp_staging_reportclientoauthsettings_clientid         = data.azurerm_key_vault_secret.amais_dxp_staging_reportclientoauthsettings_clientid[0].value
    amais_dxp_staging_ingressclientoauthsettings_clientsecret    = data.azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientsecret[0].value
    amais_dxp_staging_ingressclientoauthsettings_clientid        = data.azurerm_key_vault_secret.amais_dxp_staging_ingressclientoauthsettings_clientid[0].value
    amais_dxp_staging_aiclientoauthsettings_clientsecret         = data.azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientsecret[0].value
    amais_dxp_staging_aiclientoauthsettings_clientid             = data.azurerm_key_vault_secret.amais_dxp_staging_aiclientoauthsettings_clientid[0].value
  } : {}
  dxp_auth0_client_production_sv = var.enable_entra_dxp_client_production == false ? {
    amais_dxp_production_masterdataclientoauthsettings_clientsecret = data.azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientsecret[0].value
    amais_dxp_production_masterdataclientoauthsettings_clientid     = data.azurerm_key_vault_secret.amais_dxp_production_masterdataclientoauthsettings_clientid[0].value
    amais_dxp_production_reportclientoauthsettings_clientsecret     = data.azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientsecret[0].value
    amais_dxp_production_reportclientoauthsettings_clientid         = data.azurerm_key_vault_secret.amais_dxp_production_reportclientoauthsettings_clientid[0].value
    amais_dxp_production_ingressclientoauthsettings_clientsecret    = data.azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientsecret[0].value
    amais_dxp_production_ingressclientoauthsettings_clientid        = data.azurerm_key_vault_secret.amais_dxp_production_ingressclientoauthsettings_clientid[0].value
    amais_dxp_production_aiclientoauthsettings_clientsecret         = data.azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientsecret[0].value
    amais_dxp_production_aiclientoauthsettings_clientid             = data.azurerm_key_vault_secret.amais_dxp_production_aiclientoauthsettings_clientid[0].value
  } : {}
  kv_bunnynet_api_key_sv = var.bunny_cdn_enablement != "no" ? {
    bunnynet_api_key = data.azurerm_key_vault_secret.bunnynet_api_key[0].value
  } : {}
  kv_ubiq_shortener_api_key_sv = {
    for env in local.shortener_environments : "ubiq_shortener_${env}_api_key" => data.azurerm_key_vault_secret.ubiq_shortener_api_key[env].value
  }
  kv_ubiq_captcha_site_key_sv = {
    for env in local.captcha_environments : "ubiq_captcha_${env}_site_key" => local.captcha_site_key[env]
  }
  kv_ubiq_sendgrid_events_site_key_sv = {
    for env in local.sendgrid_events_environments : "ubiq_sendgrid_events_${env}_site_key" => local.sendgrid_events_site_key[env]
  }

  # Tagging
  common_tags = {
    deployment_method = "terraform"
    environment       = "prod"
    cost_center       = var.dev_site != "no" ? "DEVTEST" : "AMAIS_SITE"
  }
  data_tags = {
    confidential = {
      data_classification = "confidential"
    }
    public = {
      data_classification = "public"
    }
  }

  # Misc lookups and validation helpers
  lock_note                         = "This resource is locked by Terraform"
  additional_storage_containers_map = { for item in var.additional_storage_containers : item.name => item }
  quartz_cron_regex                 = "^\\s*($|#|\\w+\\s*=|(\\?|\\*|(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?(?:,(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?)*)\\s+(\\?|\\*|(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?(?:,(?:[0-5]?\\d)(?:(?:-|\\/|\\,)(?:[0-5]?\\d))?)*)\\s+(\\?|\\*|(?:[01]?\\d|2[0-3])(?:(?:-|\\/|\\,)(?:[01]?\\d|2[0-3]))?(?:,(?:[01]?\\d|2[0-3])(?:(?:-|\\/|\\,)(?:[01]?\\d|2[0-3]))?)*)\\s+(\\?|\\*|(?:0?[1-9]|[12]\\d|3[01])(?:(?:-|\\/|\\,)(?:0?[1-9]|[12]\\d|3[01]))?(?:,(?:0?[1-9]|[12]\\d|3[01])(?:(?:-|\\/|\\,)(?:0?[1-9]|[12]\\d|3[01]))?)*)\\s+(\\?|\\*|(?:[1-9]|1[012])(?:(?:-|\\/|\\,)(?:[1-9]|1[012]))?(?:L|W)?(?:,(?:[1-9]|1[012])(?:(?:-|\\/|\\,)(?:[1-9]|1[012]))?(?:L|W)?)*|\\?|\\*|(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(?:(?:-)(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))?(?:,(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)(?:(?:-)(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC))?)*)\\s+(\\?|\\*|(?:[0-6])(?:(?:-|\\/|\\,|#)(?:[0-6]))?(?:L)?(?:,(?:[0-6])(?:(?:-|\\/|\\,|#)(?:[0-6]))?(?:L)?)*|\\?|\\*|(?:MON|TUE|WED|THU|FRI|SAT|SUN)(?:(?:-)(?:MON|TUE|WED|THU|FRI|SAT|SUN))?(?:,(?:MON|TUE|WED|THU|FRI|SAT|SUN)(?:(?:-)(?:MON|TUE|WED|THU|FRI|SAT|SUN))?)*)(|\\s)+(\\?|\\*|(?:|\\d{4})(?:(?:-|\\/|\\,)(?:|\\d{4}))?(?:,(?:|\\d{4})(?:(?:-|\\/|\\,)(?:|\\d{4}))?)*))$"

  # External API identifiers (DXP, PUM, CKEditor)
  dxp_api_identifier_uri = {
    staging    = var.enable_entra_dxp_client_staging ? [for uri in data.azuread_application.dxp_api_staging[0].identifier_uris : uri if startswith(uri, "api://")][0] : null
    production = var.enable_entra_dxp_client_production ? [for uri in data.azuread_application.dxp_api_production[0].identifier_uris : uri if startswith(uri, "api://")][0] : null
  }
  pum_api = {
    staging = {
      identifier_uri = module.ubiq_resources.pum.prod.identifier_uri
      url            = module.ubiq_resources.pum.prod.url
      eventhub_fqdn  = module.ubiq_resources.pum.prod.eventhub_fqdn
    }
    prod = {
      identifier_uri = module.ubiq_resources.pum.prod.identifier_uri
      url            = module.ubiq_resources.pum.prod.url
      eventhub_fqdn  = module.ubiq_resources.pum.prod.eventhub_fqdn
    }
  }
  ckeditor_api_identifier_uri = {
    staging    = [for uri in data.azuread_application.ckeditor_api_staging.identifier_uris : uri if startswith(uri, "api://")][0]
    production = [for uri in data.azuread_application.ckeditor_api_prod.identifier_uris : uri if startswith(uri, "api://")][0]
  }

  # Geography-based AI routing
  az_us_geography   = ["us", "canada", "south america", "mexico"]
  az_asia_geography = ["asia pacific", "middle east"]
  amais_ai_url = (
    # Assign AI URL based on geography, default to europe if not US or Asia/Middle East
    contains(local.az_us_geography, lower(local.region_geography)) ?
    "https://ai-us-primary.amais.com/" : contains(local.az_asia_geography, lower(local.region_geography)) ?
    "https://ai-asia-primary.amais.com/" : "https://ai-europe-primary.amais.com/"
  )

  # Management/twingate & devops subnet access lists
  mgmt_subnets = merge({
    for subnet in module.ubiq_resources.twingate_subnets : subnet.name => {
      name                      = subnet.name
      action                    = "Allow"
      virtual_network_subnet_id = subnet.id
    }
    }, {
    for subnet in module.ubiq_resources.devops_subnets : subnet.name => {
      name                      = subnet.name
      action                    = "Allow"
      virtual_network_subnet_id = subnet.id
    }
  })

  # Bunny Shield WAF/bot-detection path exclusions
  bot_detection_disable_paths = distinct(concat(
    [
      "*/WEB/EmbedHtml/EmbedHtmlWithToken*",
      "*/email/emailtemplate/EmailTemplateSentHtml*",
      "*/ams/*",
      "*/img/*"
    ],
    var.bot_detection_disable_paths
  ))

  # Bunny Shield WAF/bot-detection category configuration
  bot_categorization = [
    {
      category = "AIScraper"
      action   = "Allow"
      overrides = [
        { bot = "ai2bot", action = "Ignore" },
        { bot = "anthropic-ai", action = "Ignore" },
        { bot = "youbot", action = "Ignore" }
      ]
    },
    {
      category = "AITool"
      action   = "Allow"
    },
    {
      category = "Ads"
      action   = "Allow"
    },
    {
      category = "Preview"
      action   = "Allow"
    },
    {
      category = "SEO"
      action   = "Allow"
    },
    {
      category = "Social"
      action   = "Allow"
    },
    {
      category = "Tool"
      action   = "Allow"
    }
  ]

  # Adds an edge rule to disable WAF for specified paths
  # Better to use WAF rule exclusions where possible (local.waf_rules_path_exclusions)
  waf_rules_disable_paths = distinct(concat(
    [
      "*/ams/*"
    ],
    var.waf_rules_disable_paths
  ))
  waf_rules_path_exclusions = {
    cms = {
      operator = "BEGINSWITH"
      value    = "/cms/"
    }
    web = {
      operator = "BEGINSWITH"
      value    = "/web/"
    }
    chat = {
      operator = "BEGINSWITH"
      value    = "/chat/"
    }
    email = {
      operator = "BEGINSWITH"
      value    = "/email/"
    }
    dxp = {
      operator = "BEGINSWITH"
      value    = "/dxp/"
    }
    img = {
      operator = "BEGINSWITH"
      value    = "/img/"
    }
    auditlog = {
      operator = "BEGINSWITH"
      value    = "/admin/audit/log"
    }
    messages = {
      operator = "BEGINSWITH"
      value    = "/messages/"
    }
  }

  # WKFlo auth settings
  wkflo_auth_settings_common = {
    CENTRAL_KEY_VAULT_URI                                     = "https://kv-uks-amais-central.vault.azure.net/"
    AmaisJwtSchema__Algorithm                                 = "RS256"
    AmaisJwtSchema__Issuer                                    = "amais-jwt-service"
    WKFloAuthBehaviourSettings__CacheEnable                   = "false"
    WKFloAuthBehaviourSettings__RetrieveTokenBeforeExpiration = "60"
    WKFloAuthBehaviourSettings__SlidingExpirationTime         = "2419200"
  }
  wkflo_auth_settings = {
    staging = {
      client_id           = "bd0e6619-8e20-4b47-b6d0-223550d668a1"
      client_principal_id = "336ae410-8bb4-4732-8230-6843bea28cf0"
      client_name         = "id-app-uks-amais-wkflo-client-staging"
      client_resource_id  = "/subscriptions/4ef55ff0-c50a-4146-8d6f-08e9e29defc9/resourceGroups/rg-global-wkflo-cae-staging/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-app-uks-amais-wkflo-client-staging"
      audience            = "api://dd92c987-87f8-4c1b-b715-25ba204054d8"
    }
    prod = {
      client_id           = "b469ff30-a867-472e-bec0-71cc4e33b1e2"
      client_principal_id = "aca17a51-c961-414a-8ed6-b5b301bcb133"
      client_name         = "id-app-uks-amais-wkflo-client-prod"
      client_resource_id  = "/subscriptions/4ef55ff0-c50a-4146-8d6f-08e9e29defc9/resourceGroups/rg-global-wkflo-cae-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-app-uks-amais-wkflo-client-prod"
      audience            = "api://f77aee83-7912-40c5-b6f8-1a5e5457ea3b"
    }
  }
}
