variable "azuread_amais_client_id" {
  type        = string
  default     = null
  description = "The client id for the AMAIS SSO Entra tenant application."
}

variable "azuread_amais_client_secret" {
  type        = string
  sensitive   = true
  default     = null
  description = "The client secret for the AMAIS SSO Entra tenant application."
}

variable "azuread_amais_tenant_id" {
  type        = string
  default     = "414ca595-4008-478e-a036-953f19733f2e"
  description = "The tenant id for the AMAIS SSO Entra tenant."
}

variable "dev_site" {
  type        = string
  default     = "no"
  description = "Whether this is a dev site or not, and what type."

  validation {
    error_message = "Valid values are `no`, `rc`, `uat`, `infratest`"
    condition     = contains(["no", "rc", "uat", "infratest"], var.dev_site)
  }
}

variable "site_name" {
  type        = string
  description = "The name of the site, used for resource naming."

  validation {
    condition     = length(var.site_name) <= 24 && can(regex("^[a-zA-Z0-9]*$", var.site_name))
    error_message = "The site_name must be 24 characters or less and contain only alphanumeric characters."
  }
}

variable "amais_application_name" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  Optional: The name of the application, used by the CMS and DXP.
  If not supplied will default to the site_name.
  DESCRIPTION

  validation {
    condition     = var.amais_application_name != null ? can(regex("^[a-zA-Z0-9]*$", var.amais_application_name)) : true
    error_message = "The amais_application_name must contain only alphanumeric characters."
  }
}

variable "templates_folder_override" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  Optional: The name of the templates folder to use for the site.
  If not supplied will default to the site_name.
  DESCRIPTION
}

variable "launch_date" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  The launch date and time of the site. The value should be supplied in local UK time.
  Set to a time more than 1 week in the past to make live immediately.
  DESCRIPTION

  validation {
    condition     = var.launch_date != null ? can(regex("^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}$", var.launch_date)) : true
    error_message = "The launch_date must be in the format YYYY-MM-DD HH:MM."
  }
}

variable "sub_id" {
  type        = string
  description = "The guid id of the subscription in which to deploy this site."
}

variable "az_long_region" {
  type        = string
  default     = "uksouth"
  description = "Azure region name, e.g eastus, southcentralus, uksouth, etc."
}

variable "amais_vnet_alias" {
  type        = string
  default     = "amais-01"
  description = "The alias for the AMAIS virtual network"

  validation {
    # should be one of a list of items
    condition     = can(regex("^(amais-01)$", var.amais_vnet_alias))
    error_message = "Allowed values for amais_vnet_alias are: amais-01."
  }
}

variable "additional_storage_containers" {
  type = list(object({
    name        = string
    access_type = string
  }))
  default     = []
  description = <<DESCRIPTION
  A list of additional storage containers to add to the main storage account.

  ```terraform
  additional_containers = [
    {
      name  = "container1"
      access_type = "private"
    },
    {
      name  = "container2"
      access_type = "blob"
    }
  ]
  ```
  DESCRIPTION
}

variable "enable_storage_blob_diagnostic_settings" {
  type        = bool
  default     = true
  description = "Enables diagnostic settings for the storage account blob service to send logs to Log Analytics"
}

variable "enable_storage_shared_key_access" {
  type        = bool
  default     = false
  description = "Enable or disable shared key access for the storage account"
}

variable "allow_public_blobs" {
  type        = bool
  default     = false
  description = "Allow public access to blobs in the storage account"
}

variable "sql_admin_login" {
  type        = string
  default     = "superadmin"
  description = "The username for the SQL server admin login"
}

variable "sql_entra_login_only" {
  type        = bool
  default     = true
  description = "Enforce Entra login only for the SQL server"
}

variable "enable_sql_advanced_auditing" {
  type        = bool
  default     = true
  description = "Enables auditing for the SQL server to blob storage"
}

variable "enable_sql_ms_support_auditing" {
  type        = bool
  default     = true
  description = "Enables Microsoft support actions auditing for the SQL server to blob storage"
}

variable "enable_sqldb_advanced_auditing" {
  type        = bool
  default     = false
  description = "Enables auditing for the SQL database to blob storage"
}

variable "enable_sqldb_diagnostic_settings" {
  type        = bool
  default     = false
  description = "Enables full diagnostic settings for the SQL database to send logs to Log Analytics"
}

variable "sql_fw_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default     = {}
  description = <<DESCRIPTION
  Map of SQL firewall rule objects to create"

  ```terraform
  sql_fw_rules = {
    "Client1" = {
      start_ip_address = "1.2.3.4"
      end_ip_address   = "1.2.3.4"
    },
    "ClientRange2" = {
      start_ip_address = "1.2.4.10"
      end_ip_address   = "1.2.4.20"
    }
  ```
  DESCRIPTION
}

variable "enable_sql_azure_firewall_exception" {
  type        = bool
  default     = false
  description = "Enable or disable Azure IPs firewall rule exception for the SQL server"
}

variable "sqldb_sku" {
  type        = string
  default     = "S0"
  description = "The sku for the SQL database"
}

variable "enable_zone_redundant_sql" {
  type        = bool
  default     = false
  description = "Enable zone redundancy for the SQL server, this is only supported with premium and business critical plans"
}

variable "sqldb_max_size_gb" {
  type        = number
  default     = 2
  description = "The maximum size of the SQL database in GB"

  validation {
    condition     = var.sqldb_max_size_gb >= 2
    error_message = "The sqldb_max_size_gb must be greater than 2"
  }
}

variable "sqldb_pitr_days" {
  type        = number
  default     = 14
  description = "The number of days to retain Point In Time Restore backups for the SQL database"
}

variable "sqldb_monthly_retention" {
  type        = string
  default     = "P6M"
  description = "The number of monthly backups to retain for the SQL database, must be in ISO 8601 format."

  validation {
    condition     = can(regex("^P(\\d+[YMD])*(T(\\d+[HMS])*)?$", var.sqldb_monthly_retention))
    error_message = "The sqldb_monthly_retention must be in ISO 8601 format."
  }
}

variable "provision_from_baseline" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Start a new site from the Baseline site's content: the latest nightly snapshot of the Baseline database, blob
  container and static website ($web) are imported once, before the normal database release runs. Content is copied
  as-is; files the module uploads to $web are kept.
  It fires whenever Terraform creates the SQL database, including a replacement of an existing database. Once a run has
  completed, the completion marker it writes (container 'provisioning', blob 'baseline-provision.json' in the site's
  storage account) makes later runs no-ops, so nothing is copied twice. Do not turn it on for an existing site unless
  Baseline content is wanted when its database is next re-created. Turning it off changes nothing.
  Cannot be enabled for the Baseline site itself (site key, the templates folder, 'Baseline').
  DESCRIPTION

  validation {
    condition     = !var.provision_from_baseline || lower(local.templates_folder) != "baseline"
    error_message = "The Baseline site cannot be provisioned from itself: provision_from_baseline must be false when the site key (templates_folder_override, or site_name) is 'Baseline'."
  }
}

variable "service_plan_sku" {
  type        = string
  default     = "P0v3"
  description = "The sku for the app service plan"

  validation {
    condition     = can(regex("^[B|S|P]", var.service_plan_sku))
    error_message = <<DESCRIPTION
    This module supports basic, standard or premium service plan sku's so must start with either 'B', 'S' or 'P'.
    Value is case sensitive.
    For a list of available sku's see https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans
    DESCRIPTION
  }
}

variable "enable_zone_redundant_app_service" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Enable zone redundancy for the app service plan, this is only supported with premium v2 or v3 plans.
  Will only take effect if the region supports zones.
  DESCRIPTION
}

variable "app_instance_count" {
  type        = number
  default     = null
  description = <<DESCRIPTION
  The number of instances to run the app service on, if null will default to the number of zones in the region.
  Only takes effect if enable_zone_redundant_app_service is true.
  DESCRIPTION

  validation {
    condition     = var.app_instance_count != null ? var.app_instance_count > 0 : true
    error_message = "The app_instance_count must be greater than 0 or null."
  }
}

variable "web_domains" {
  type        = list(string)
  default     = []
  description = "List of domain names to add to the web app"

  validation {
    condition     = alltrue([for domain in var.web_domains : can(regex("^[a-z0-9.-]*$", domain))])
    error_message = "The web_domains must contain only alphanumeric characters, hyphens and periods."
  }
}

variable "https_only_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable HTTPS only for the web app"
}

variable "https_only_enabled_staging" {
  type        = bool
  default     = true
  description = "Enable or disable HTTPS only for the web app staging slot"
}

variable "min_tls_cipher_suite" {
  type        = string
  default     = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  description = "The minimum TLS cipher suite to use for the web app"
}

variable "min_tls_cipher_suite_staging" {
  type        = string
  default     = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  description = "The minimum TLS cipher suite to use for the web app staging slot"
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version to use for the web app"
}

variable "minimum_tls_version_staging" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version to use for the web app staging slot"
}

variable "scm_minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version to use for the SCM site of the web app"
}

variable "scm_minimum_tls_version_staging" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version to use for the SCM site of the web app staging slot"
}

variable "amais_response_time_alert_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable the standard response time alert"
}

variable "amais_server_errors_alert_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable the standard server errors alert"
}

variable "amais_health_check_alert_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable the standard health check alert"
}

variable "resource_metric_alerts_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable the Azure resource metric alerts"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
  Key-value pairs of tags to apply to all resources in this site"

  ```terraform
  tags = {
    environment = "production"
    owner       = "team"
  }
  ```
  DESCRIPTION
}

variable "add_delete_locks" {
  type        = bool
  default     = true
  description = "Add delete locks to important resources"
}

variable "create_staging_slot" {
  type        = bool
  default     = true
  description = "Create the staging slot for the web app"
}

variable "app_stack_dotnet_version" {
  type        = string
  default     = "v10.0"
  description = "The version of .NET to use for the stack settings"

  validation {
    condition     = contains(["v8.0", "v10.0"], var.app_stack_dotnet_version)
    error_message = "The app_stack_dotnet_version must be one of v8.0, v10.0."
  }
}

variable "app_stack_dotnet_version_staging" {
  type        = string
  description = "The version of .NET to use for the stack settings staging slot, if null will use the same as the main app."
  default     = null

  validation {
    condition     = var.app_stack_dotnet_version_staging != null ? contains(["v8.0", "v10.0"], var.app_stack_dotnet_version_staging) : true
    error_message = "The app_stack_dotnet_version_staging must be one of v8.0, v10.0 or null."
  }
  nullable = true
}

variable "app_settings" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
  A map of key-value pairs for additional app settings and custom values to assign to the web app,
  these will be merged with the default settings.
  The settings supplied to the variable will override the default settings if a key name matches.

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
  ```
  DESCRIPTION
}

variable "app_settings_staging" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
  A map of key-value pairs for additional app settings and custom values to assign to the web app staging slot (if created),
  these will be merged with the default settings.
  The settings supplied to the variable will override the default settings if a key name matches

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
  ```
  DESCRIPTION
}

variable "app_sticky_settings_names" {
  type        = list(string)
  default     = []
  description = "Optional: A list of sticky settings to assign to the web app in addition to the default list."
}

variable "enable_page_data_generation_job_slot" {
  type        = string
  default     = "none"
  description = "The slot to enable the page data generation job on, either production, staging or none"

  validation {
    condition     = can(regex("^(production|staging|none)$", var.enable_page_data_generation_job_slot))
    error_message = "The enable_page_data_generation_job_slot must be either production, staging or none."

  }
}

variable "page_data_generation_job_cron_expression" {
  type        = string
  default     = "0 0 0 ? * *"
  description = "The cron expression for the page data generation job on the production slot"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.page_data_generation_job_cron_expression)
      )
    )
    error_message = "The page_data_generation_job_cron_expression must be a valid 6 field cron expression."
  }
}

variable "directory_and_sso_integration_provider" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  Provider to use for directory and SSO integration, supported providers are:

  Blackbaud
  Veracross
  GG4L
  DESCRIPTION

  validation {
    condition = (
      var.directory_and_sso_integration_provider != null ? can(regex("^(Blackbaud|Veracross|GG4L)$", var.directory_and_sso_integration_provider)) : true
    )
    error_message = "directory_and_sso_integration_provider must be either Blackbaud, Veracross, GG4L or null"
  }
}

variable "blackbaud_account_name" {
  type        = string
  default     = null
  description = "The Blackbaud account name"

  validation {
    condition     = var.enable_blackbaud_sso ? var.blackbaud_account_name != null : true
    error_message = "The blackbaud_account_name must be set if enable_blackbaud_sso is true."
  }
}

variable "enable_blackbaud_sso" {
  type        = bool
  default     = false
  description = "Enable Single Sign-On (SSO) for Blackbaud integration"

  validation {
    condition     = var.directory_and_sso_integration_provider != "Blackbaud" ? var.enable_blackbaud_sso == false : true
    error_message = "enable_blackbaud_sso requires directory_and_sso_integration_provider to be 'Blackbaud'."
  }
}

variable "blackbaud_sso_auth_api_slug_production" {
  type        = string
  default     = null
  description = "The Blackbaud SSO Auth API slug to append to the SSO URL for production slot Blackbaud integration"

  validation {
    condition     = var.enable_blackbaud_sso ? var.blackbaud_sso_auth_api_slug_production != null : true
    error_message = "The blackbaud_sso_auth_api_slug_production must be set if enable_blackbaud_sso is true."
  }
}

variable "blackbaud_sso_auth_api_slug_staging" {
  type        = string
  default     = null
  description = "The Blackbaud SSO Auth API slug to append to the SSO URL for staging slot Blackbaud integration"

  validation {
    condition     = var.enable_blackbaud_sso ? var.blackbaud_sso_auth_api_slug_staging != null : true
    error_message = "The blackbaud_sso_auth_api_slug_staging must be set if enable_blackbaud_sso is true."
  }
}

variable "blackbaud_oauth_sso_api_key_production" {
  type        = string
  sensitive   = true
  default     = null
  description = "The production slot Blackbaud OAuth API key for SSO integration"

  validation {
    condition     = var.enable_blackbaud_sso ? var.blackbaud_oauth_sso_api_key_production != null : true
    error_message = "The blackbaud_oauth_sso_api_key_production must be set if enable_blackbaud_sso is true."
  }
}

variable "blackbaud_oauth_sso_api_key_staging" {
  type        = string
  sensitive   = true
  default     = null
  description = "The staging slot Blackbaud OAuth API key for SSO integration"

  validation {
    condition     = var.enable_blackbaud_sso ? var.blackbaud_oauth_sso_api_key_staging != null : true
    error_message = "The blackbaud_oauth_sso_api_key_staging must be set if enable_blackbaud_sso is true."
  }
}

variable "enable_BlackbaudSynchJobSettings" {
  type        = bool
  default     = true
  description = "Enable or disable the Blackbaud Synch Job Settings"
}

variable "BlackbaudSynchJobSettings_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the Blackbaud Synch Job Settings on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.BlackbaudSynchJobSettings_slot_name))
    error_message = "The BlackbaudSynchJobSettings_slot_name must be either production or staging."
  }
}

variable "BlackbaudSynchJobSettings_schedule" {
  type        = string
  default     = "0 0 4 * * ?"
  description = "The cron expression for the Blackbaud Synch Job Settings (Scheduler__BlackbaudSynchJob)"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.BlackbaudSynchJobSettings_schedule)
      )
    )
    error_message = "The BlackbaudSynchJobSettings_schedule must be a valid 6 field cron expression."
  }
}

variable "enable_BlackbaudSynchAthleticsUpdateJobSetting" {
  type        = bool
  default     = false
  description = "Enable or disable the Blackbaud Synch Athletics Update Job Settings"
}

variable "BlackbaudSynchAthleticsUpdateJobSetting_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the Blackbaud Synch Job Settings on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.BlackbaudSynchAthleticsUpdateJobSetting_slot_name))
    error_message = "The BlackbaudSynchAthleticsUpdateJobSetting_slot_name must be either production or staging."
  }
}

variable "BlackbaudSynchAthleticsUpdateJobSetting_schedule" {
  type        = string
  default     = "0 0 11-23 * * ?"
  description = "The cron expression for the Blackbaud Synch Athletics Update Job Settings (Scheduler__BlackbaudSynchAthleticsUpdateJob)"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.BlackbaudSynchAthleticsUpdateJobSetting_schedule)
      )
    )
    error_message = "The BlackbaudSynchAthleticsUpdateJobSetting_schedule must be a valid 6 field cron expression."
  }
}

variable "enable_dxp_integration_production" {
  type        = bool
  default     = true
  description = "Enable or disable the DXP integration on the production slot"
}

variable "enable_dxp_integration_staging" {
  type        = bool
  default     = true
  description = "Enable or disable the DXP integration on the staging slot"
}

variable "enable_authorize_net_integration_production" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Enable or disable the Authorize.Net integration on the production slot.
  If enabled, the following variables must be set:

  authorize_net_api_login_id
  authorize_net_public_client_key
  authorize_net_transaction_key

  DESCRIPTION
}

variable "enable_authorize_net_integration_staging" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Enable or disable the Authorize.Net integration on the staging slot.
  If enabled, the following variables must be set:

  authorize_net_api_login_id
  authorize_net_public_client_key
  authorize_net_transaction_key
  DESCRIPTION
}

variable "authorize_net_api_login_id" {
  type        = string
  sensitive   = true
  default     = null
  description = "The Authorize.Net API login ID"

  validation {
    condition = (
      var.enable_authorize_net_integration_production || var.enable_authorize_net_integration_staging
      ? var.authorize_net_api_login_id != null
      : true
    )
    error_message = "The authorize_net_api_login_id must be set if enable_authorize_net_integration is true."
  }
}

variable "authorize_net_public_client_key" {
  type        = string
  sensitive   = true
  default     = null
  description = "The Authorize.Net public client key"

  validation {
    condition = (
      var.enable_authorize_net_integration_production || var.enable_authorize_net_integration_staging
      ? var.authorize_net_public_client_key != null
      : true
    )
    error_message = "The authorize_net_public_client_key must be set if enable_authorize_net_integration is true."
  }
}

variable "authorize_net_transaction_key" {
  type        = string
  sensitive   = true
  default     = null
  description = "The Authorize.Net transaction key"

  validation {
    condition = (
      var.enable_authorize_net_integration_production || var.enable_authorize_net_integration_staging
      ? var.authorize_net_transaction_key != null
      : true
    )
    error_message = "The authorize_net_transaction_key must be set if enable_authorize_net_integration is true."
  }
}

variable "enable_form_payments_production" {
  type        = bool
  default     = false
  description = "Enable or disable form payments on the production slot"
}

variable "enable_form_payments_staging" {
  type        = bool
  default     = false
  description = "Enable or disable form payments on the staging slot"
}

variable "enable_contacts_module_production" {
  type        = bool
  default     = false
  description = "Enable or disable the contacts module on the production slot"
}

variable "enable_contacts_module_staging" {
  type        = bool
  default     = false
  description = "Enable or disable the contacts module on the staging slot"
}

variable "disable_branch_redirects_production" {
  type        = bool
  default     = false
  description = "Disable branch redirects on the production slot (DISABLE_BRANCH_REDIRECTS = 'true')"
}

variable "disable_branch_redirects_staging" {
  type        = bool
  default     = true
  description = "Disable branch redirects on the staging slot (DISABLE_BRANCH_REDIRECTS = 'true')"
}

variable "calendar_time_zone" {
  type        = string
  default     = null
  description = "The time zone for the calendar module"

  validation {
    condition     = var.calendar_time_zone != null ? can(regex("^[a-zA-Z0-9/_ ]*$", var.calendar_time_zone)) : true
    error_message = "The calendar_time_zone must contain only alphanumeric characters, forward slash, underscores and spaces."
  }
}

variable "calendar_time_zone_id" {
  type        = string
  default     = null
  description = "The time zone ID for the calendar module"

  validation {
    condition     = var.calendar_time_zone_id != null ? can(regex("^[a-zA-Z0-9/_ ]*$", var.calendar_time_zone_id)) : true
    error_message = "The calendar_time_zone_id must contain only alphanumeric characters, forward slash, underscores and spaces."
  }
}

variable "enable_custom_send_grid_config_production" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Enable or disable custom SendGrid configuration on the production slot.
  Enabling it also registers the site with the Ubiq SendGrid event receiver and adds the SendGridEvents__* app
  settings to the production slot.
  If enabled, the following variables must be set:

  send_grid_email_sender
  send_grid_key
  send_grid_marketing_unsubscribe_group_id
  send_grid_unsubscribe_groups
  send_grid_user
  DESCRIPTION
}

variable "enable_custom_send_grid_config_staging" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Enable or disable custom SendGrid configuration on the staging slot.
  Enabling it also registers the site with the Ubiq SendGrid event receiver and adds the SendGridEvents__* app
  settings to the staging slot.
  If enabled, the following variables must be set:

  send_grid_email_sender
  send_grid_key
  send_grid_marketing_unsubscribe_group_id
  send_grid_unsubscribe_groups
  send_grid_user
  DESCRIPTION
}

variable "send_grid_email_sender" {
  type        = string
  default     = null
  description = "The email address to use as the sender for SendGrid emails for custom SendGrid configuration"

  validation {
    condition = (
      var.enable_custom_send_grid_config_production || var.enable_custom_send_grid_config_staging
      ? var.send_grid_email_sender != null
      : true
    )
    error_message = <<DESCRIPTION
    The send_grid_email_sender must be set if enable_custom_send_grid_config_production or enable_custom_send_grid_config_staging is true.
    DESCRIPTION
  }
}

variable "send_grid_key_production" {
  type        = string
  sensitive   = true
  default     = null
  description = "The production slot SendGrid API key for custom SendGrid configuration"

  validation {
    condition     = var.enable_custom_send_grid_config_production ? var.send_grid_key_production != null : true
    error_message = "The send_grid_key_production must be set if enable_custom_send_grid_config_production is true."
  }
}

variable "send_grid_key_staging" {
  type        = string
  sensitive   = true
  default     = null
  description = "The staging slot SendGrid API key for custom SendGrid configuration"

  validation {
    condition     = var.enable_custom_send_grid_config_staging ? var.send_grid_key_staging != null : true
    error_message = "The send_grid_key_staging must be set if enable_custom_send_grid_config_staging is true."
  }
}

variable "send_grid_marketing_unsubscribe_group_id" {
  type        = string
  default     = null
  description = "The SendGrid marketing unsubscribe group ID for custom SendGrid configuration"

  validation {
    condition = (
      var.enable_custom_send_grid_config_production || var.enable_custom_send_grid_config_staging
      ? var.send_grid_marketing_unsubscribe_group_id != null
      : true
    )
    error_message = <<DESCRIPTION
    The send_grid_marketing_unsubscribe_group_id must be set if enable_custom_send_grid_config_production or
    enable_custom_send_grid_config_staging is true.
    DESCRIPTION
  }
}

variable "send_grid_unsubscribe_groups" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  A json blob of SendGrid unsubscribe group names for custom SendGrid configuration, in the format:

  ```json
  {'unsubscribeGroups':[{'name':'group1','id':'xxxxx'},{'name':'group2','id':'xxxxx'},{'name':'group3','id':'xxxxx'}]}
  ```
  DESCRIPTION

  validation {
    condition = (
      var.enable_custom_send_grid_config_production || var.enable_custom_send_grid_config_staging
      ? length(var.send_grid_unsubscribe_groups) > 0
      : true
    )
    error_message = <<DESCRIPTION
    The send_grid_unsubscribe_groups must be set if enable_custom_send_grid_config_production or enable_custom_send_grid_config_staging is true.
    DESCRIPTION
  }
}

variable "send_grid_user" {
  type        = string
  default     = null
  description = "The SendGrid user for custom SendGrid configuration"

  validation {
    condition     = var.enable_custom_send_grid_config_production || var.enable_custom_send_grid_config_staging ? var.send_grid_user != null : true
    error_message = "The send_grid_user must be set if enable_custom_send_grid_config_production or enable_custom_send_grid_config_staging is true."
  }
}

variable "veracross_account_name" {
  type        = string
  default     = null
  description = "The Veracross account name"

  validation {
    condition     = var.directory_and_sso_integration_provider == "Veracross" ? var.veracross_account_name != null : true
    error_message = "The veracross_account_name must be set if directory_and_sso_integration_provider is 'Veracross'."
  }
  validation {
    condition     = var.enable_veracross_sso ? var.veracross_account_name != null : true
    error_message = "The veracross_account_name must be set if enable_veracross_sso is true."
  }
}

variable "enable_veracross_sso" {
  type        = bool
  default     = false
  description = "Enable Single Sign-On (SSO) for Veracross integration"

  validation {
    condition     = var.directory_and_sso_integration_provider != "Veracross" ? var.enable_veracross_sso == false : true
    error_message = "enable_veracross_sso requires directory_and_sso_integration_provider to be 'Veracross'."
  }
}

variable "veracross_oauth_settings_scope" {
  type        = string
  default     = null
  description = "The Veracross OAuth settings scope"

  validation {
    condition     = var.directory_and_sso_integration_provider == "Veracross" ? var.veracross_oauth_settings_scope != null : true
    error_message = "The veracross_oauth_settings_scope must be set if directory_and_sso_integration_provider is 'Veracross'."
  }
}

variable "veracross_oauth_settings_client_id" {
  type        = string
  sensitive   = true
  default     = null
  description = "The value for OAuthSettings__ClientId"

  validation {
    condition     = var.directory_and_sso_integration_provider == "Veracross" ? var.veracross_oauth_settings_client_id != null : true
    error_message = "The veracross_oauth_settings_client_id must be set if directory_and_sso_integration_provider is 'Veracross'."
  }
}

variable "veracross_oauth_settings_client_secret" {
  type        = string
  sensitive   = true
  default     = null
  description = "The value for OAuthSettings__ClientSecret"

  validation {
    condition     = var.directory_and_sso_integration_provider == "Veracross" ? var.veracross_oauth_settings_client_secret != null : true
    error_message = "The veracross_oauth_settings_client_secret must be set if directory_and_sso_integration_provider is 'Veracross'."
  }
}

variable "enable_VeracrossSynchJobSettings" {
  type        = bool
  default     = false
  description = "Enable or disable the Veracross Synch Job Settings - VeracrossSynchJobSettings__IsEnable"
}

variable "VeracrossSynchJobSettings_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the Veracross Synch Job Settings on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.VeracrossSynchJobSettings_slot_name))
    error_message = "The VeracrossSynchJobSettings_slot_name must be either production or staging."
  }
}

variable "veracross_synch_job_schedule_cron_expression" {
  type        = string
  default     = "0 0 4 * * ?"
  description = "The cron expression for the Veracross Synch Job Settings - Scheduler__VeracrossSynchJob"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.veracross_synch_job_schedule_cron_expression)
      )
    )
    error_message = "The veracross_synch_job_schedule_cron_expression must be a valid 6 field cron expression."
  }
}

variable "enable_gg4l_directory_synch" {
  type        = bool
  default     = false
  description = "Enable or disable the GG4L directory sync"

  validation {
    condition     = var.directory_and_sso_integration_provider != "GG4L" ? var.enable_gg4l_directory_synch == false : true
    error_message = "enable_gg4l_directoy_sync requires directory_and_sso_integration_provider to be 'GG4L'."
  }
}

variable "gg4l_synch_client_id" {
  type        = string
  sensitive   = true
  default     = null
  description = "The value for GG4L_SynchClientId"

  validation {
    condition     = var.enable_gg4l_directory_synch ? var.gg4l_synch_client_id != null : true
    error_message = "The gg4l_synch_client_id must be set if enable_gg4l_directory_synch is true."
  }
}

variable "gg4l_synch_client_secret" {
  type        = string
  sensitive   = true
  default     = null
  description = "The value for GG4L_SynchClientSecret"

  validation {
    condition     = var.enable_gg4l_directory_synch ? var.gg4l_synch_client_secret != null : true
    error_message = "The gg4l_synch_client_secret must be set if enable_gg4l_directory_synch is true."
  }
}

variable "enable_gg4l_sso" {
  type        = bool
  default     = false
  description = "Enable Single Sign-On (SSO) for GG4L integration"

  validation {
    condition     = var.directory_and_sso_integration_provider != "GG4L" ? var.enable_gg4l_sso == false : true
    error_message = "enable_gg4l_sso requires directory_and_sso_integration_provider to be 'GG4L'."
  }
}

variable "gg4l_oauth_settings_client_id" {
  type        = string
  sensitive   = true
  default     = null
  description = "The value for OAuthSettings__ClientId"

  validation {
    condition     = var.enable_gg4l_sso ? var.gg4l_oauth_settings_client_id != null : true
    error_message = "The gg4l_oauth_settings_client_id must be set if enable_gg4l_sso is true."
  }
}

variable "gg4l_oauth_settings_client_secret" {
  type        = string
  sensitive   = true
  default     = null
  description = "The value for OAuthSettings__ClientSecret"

  validation {
    condition     = var.enable_gg4l_sso ? var.gg4l_oauth_settings_client_secret != null : true
    error_message = "The gg4l_oauth_settings_client_secret must be set if enable_gg4l_sso is true."
  }
}

variable "oauth_authorize_url_override" {
  type        = string
  default     = null
  description = "This will override the OAuthSettings__AuthorizeUrl for SSO integrations."
}

variable "custom_cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = "Optional: A list of URLs to add to the CORs allowed origin list on the web app. URLs will be added to both slots."

  validation {
    condition = (
      alltrue([for origin in var.custom_cors_allowed_origins : can(regex("^https:\\/\\/[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}(\\/[^\\s]*)?$", origin))])
    )
    error_message = "Each item in custom_cors_allowed_origins must be a valid https URL."
  }
}

variable "enable_email_module_production" {
  type        = bool
  default     = false
  description = "Enable or disable the email module on the production slot"
}

variable "enable_email_module_staging" {
  type        = bool
  default     = false
  description = "Enable or disable the email module on the staging slot"
}

variable "EmailStatsSyncJobSettings_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the EmailStats Sync Job Settings on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.EmailStatsSyncJobSettings_slot_name))
    error_message = "The EmailStatsSyncJobSettings_slot_name must be either production or staging."
  }
}

variable "EmailStats_sync_job_schedule_cron_expression" {
  type        = string
  default     = "0 0/30 * * * ?"
  description = "The cron expression for the EmailStats Sync Job Settings - Scheduler__EmailStatsSyncJob"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.EmailStats_sync_job_schedule_cron_expression)
      )
    )
    error_message = "The EmailStats_sync_job_schedule_cron_expression must be a valid 6 field cron expression."
  }
}

variable "EmailSupressionsSyncJobSettings_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the EmailSupressions Sync Job Settings on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.EmailSupressionsSyncJobSettings_slot_name))
    error_message = "The EmailSupressionsSyncJobSettings_slot_name must be either production or staging."
  }
}

variable "EmailSupressions_sync_job_schedule_cron_expression" {
  type        = string
  default     = "0 0 0/1 * * ?"
  description = "The cron expression for the EmailSupressions Sync Job Settings - Scheduler__EmailSupressionsSyncJob"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.EmailSupressions_sync_job_schedule_cron_expression)
      )
    )
    error_message = "The EmailSupressions_sync_job_schedule_cron_expression must be a valid 6 field cron expression."
  }
}

variable "enable_workflow_module_production" {
  type        = bool
  default     = false
  description = "Enable or disable the workflow module on the production slot"

  validation {
    error_message = "enable_custom_send_grid_config_production must be set to true if enable_workflow_module_production is true."
    condition     = var.enable_workflow_module_production ? var.enable_custom_send_grid_config_production : true
  }
}

variable "enable_workflow_module_staging" {
  type        = bool
  default     = false
  description = "Enable or disable the workflow module on the staging slot"

  validation {
    error_message = "enable_custom_send_grid_config_staging must be set to true if enable_workflow_module_staging is true."
    condition     = var.enable_workflow_module_staging ? var.enable_custom_send_grid_config_staging : true
  }
}

variable "WorkflowEngineJob_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the WorkflowEngineJob schedule on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.WorkflowEngineJob_slot_name))
    error_message = "The WorkflowEngineJob_slot_name must be either production or staging."
  }
}

variable "WorkflowEngineJob_schedule_cron_expression" {
  type        = string
  default     = "0 0/10 * * * ?"
  description = "The cron expression for the WorkflowEngineJob Synch Job Settings - Scheduler__WorkflowEngineJob"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.WorkflowEngineJob_schedule_cron_expression)
      )
    )
    error_message = "The WorkflowEngineJob_schedule_cron_expression must be a valid 6 field cron expression."
  }
}

variable "scheduler_manager_slot_name" {
  type        = string
  default     = "production"
  description = "Which slot to enable the Scheduler Manager schedule on, either production or staging"

  validation {
    condition     = can(regex("^(production|staging)$", var.scheduler_manager_slot_name))
    error_message = "The WorkflowEngineJob_slot_name must be either production or staging."
  }
}

variable "scheduler_manager_job_cron_expression" {
  type        = string
  default     = "0 0/10 * * * ?"
  description = "The cron expression for the Scheduler Manager Sync Job Settings - Scheduler__ManagerJob"

  validation {
    condition = (
      can(
        regex(local.quartz_cron_regex, var.scheduler_manager_job_cron_expression)
      )
    )
    error_message = "The scheduler_manager_job_cron_expression must be a valid 6 field cron expression."
  }
}

variable "weglot_redirection_enabled" {
  type        = bool
  default     = false
  description = "Enable authentication redirection for Weglot"
}

variable "enable_ai_chatbot_production" {
  type        = bool
  default     = false
  description = "Enable or disable the AI chatbot on the production slot"
}

variable "enable_ai_chatbot_staging" {
  type        = bool
  default     = false
  description = "Enable or disable the AI chatbot on the staging slot"
}

variable "ai_chatbot_model_staging" {
  type        = string
  default     = "gpt-4.1-mini"
  description = "The model to use for the AI chatbot on the staging slot (dev sites only)"
}

variable "ai_chatbot_model_production" {
  type        = string
  default     = "gpt-4.1-mini"
  description = "The model to use for the AI chatbot on the production slot"
}

variable "ai_chatbot_embedding_model_production" {
  type        = string
  default     = "text-embedding-3-large"
  description = "The embedding model to use with the AI chatbot on the production slot"
}

variable "ai_chatbot_embedding_model_staging" {
  type        = string
  default     = "text-embedding-3-large"
  description = "The embedding model to use with the AI chatbot on the staging slot (dev sites only)"
}

variable "enable_entra_dxp_client_staging" {
  type        = bool
  default     = true
  description = "Use the platform DXP client managed identities on the staging slot for authentication to the DXP"
}

variable "enable_entra_dxp_client_production" {
  type        = bool
  default     = true
  description = "Use the platform DXP client managed identities on the production slot for authentication to the DXP"
}

variable "bunny_cdn_enablement" {
  type        = string
  default     = "yes"
  description = <<DESCRIPTION
  Enablement of Bunny CDN. Options are 'yes' or 'no'
  - 'no' will disable Bunny CDN and route traffic directly to the web app and storage hosts
  - 'yes' will enable Bunny CDN and use Bunny-backed hostnames
  DESCRIPTION

  validation {
    condition     = can(regex("^(yes|no)$", var.bunny_cdn_enablement))
    error_message = "The bunny_cdn_enablement must be either 'yes' or 'no'"
  }
}

variable "bunny_pullzone_config" {
  type = object({
    pullzone_name              = optional(string)
    cache_enabled              = optional(bool)
    cache_expiration_time      = optional(number)
    cache_errors               = optional(bool)
    cache_vary                 = optional(list(string))
    cache_chunked              = optional(bool)
    cors_enabled               = optional(bool)
    cors_extensions            = optional(list(string))
    add_canonical_header       = optional(bool)
    safehop_enabled            = optional(bool)
    safehop_connection_timeout = optional(number)
    safehop_response_timeout   = optional(number)
    safehop_retry_count        = optional(number)
    safehop_retry_delay        = optional(number)
    safehop_retry_reasons      = optional(list(string))
    block_root_path            = optional(bool)
    sort_querystring           = optional(bool)
    strip_cookies              = optional(bool)
    tls_level                  = optional(string)
    request_coalescing_enabled = optional(bool)
    log_forward_enabled        = optional(bool)
    log_forward_format         = optional(string)
    log_forward_port           = optional(number)
    log_forward_protocol       = optional(string)
    log_forward_server         = optional(string)
    log_forward_token          = optional(string)
    origin = optional(object({
      verify_ssl          = optional(bool)
      follow_redirects    = optional(bool)
      forward_host_header = optional(bool)
      host_header         = optional(string)
      middleware_script   = optional(number)
    }))
    routing = optional(object({
      tier              = optional(string)
      zones             = optional(list(string))
      blocked_countries = optional(list(string))
    }))
    optimizer_enabled                     = optional(bool)
    optimizer_webp                        = optional(bool)
    optimizer_dynamic_image_api           = optional(bool)
    optimizer_burrow                      = optional(bool)
    optimizer_classes_force               = optional(bool)
    optimizer_html_prerender              = optional(bool)
    optimizer_minify_css                  = optional(bool)
    optimizer_minify_js                   = optional(bool)
    optimizer_smartimage                  = optional(bool)
    optimizer_smartimage_desktop_maxwidth = optional(number)
    optimizer_smartimage_desktop_quality  = optional(number)
    optimizer_smartimage_mobile_maxwidth  = optional(number)
    optimizer_smartimage_mobile_quality   = optional(number)
    optimizer_watermark                   = optional(bool)
    optimizer_watermark_borderoffset      = optional(number)
    optimizer_watermark_minsize           = optional(number)
    optimizer_watermark_position          = optional(string)
    optimizer_watermark_url               = optional(string)
  })
  default     = {}
  description = <<DESCRIPTION
  Configuration for the bunny pullzone.
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone
  DESCRIPTION

  validation {
    error_message = "bunny_cdn_enablement must be 'yes' if bunny_pullzone_config is set."
    condition     = length(keys(var.bunny_pullzone_config)) > 0 && !alltrue([for v in values(var.bunny_pullzone_config) : v == null]) ? var.bunny_cdn_enablement == "yes" : true
  }
}

variable "bunny_pullzone_additional_edge_rules" {
  type = map(object({
    description = string
    enabled     = optional(bool, true)
    priority    = number
    actions = list(object({
      type       = string
      parameter1 = optional(string)
      parameter2 = optional(string)
      parameter3 = optional(string)
    }))
    match_type = string
    triggers = list(object({
      type       = string
      match_type = string
      patterns   = list(string)
      parameter1 = optional(string)
      parameter2 = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Additional Bunny CDN edge rules to apply.
  Priority is an integer value that determines the order of the rules, starting at 1.
  The specified priority will be used to order the additional rules relative to each other.
  Rules will be added after the default rules.
  DESCRIPTION

  validation {
    error_message = "bunny_cdn_enablement must not be 'no' if bunny_pullzone_additional_edge_rules is set."
    condition     = length(keys(var.bunny_pullzone_additional_edge_rules)) > 0 && !alltrue([for v in values(var.bunny_pullzone_additional_edge_rules) : v == null]) ? var.bunny_cdn_enablement != "no" : true
  }
}

variable "bunny_pullzone_shield_config" {
  type = object({
    tier                      = optional(string)
    whitelabel                = optional(bool)
    whitelabel_block          = optional(string)
    whitelabel_challenge      = optional(string)
    whitelabel_rate_limit     = optional(string)
    upload_scanning_antivirus = optional(string)
    upload_scanning_csam      = optional(string)
    ddos = optional(object({
      level            = optional(string, "Low")
      challenge_window = optional(number, 3600)
    }))
    waf = optional(object({
      # Ensure variable defaults matches the default in bunny.waf for an empty variable for consistency
      enabled                       = optional(bool)
      allowed_http_methods          = optional(list(string), ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      allowed_http_versions         = optional(list(string))
      allowed_request_content_types = optional(list(string))
      blocking_sensitivity          = optional(number)
      body_limit_request            = optional(string)
      body_limit_response           = optional(string)
      detection_sensitivity         = optional(number)
      execution_sensitivity         = optional(number)
      log_headers                   = optional(bool)
      log_headers_excluded          = optional(list(string))
      mode                          = optional(string, "Block")
      realtime_threat_intelligence  = optional(bool)
      rules_disabled                = optional(list(string), ["952100", "953100", "953101", "953110", "953120", "DDoS-0ad5f8", "SHL-G8", "941160", "932125"])
      rules_logonly                 = optional(list(string), ["932235", "941100", "921130", "933120", "942100", "942550", "932370", "951120"])
    }))
    bot_detection = optional(object({
      complex_fingerprinting  = optional(bool)
      fingerprint_aggression  = optional(number)
      fingerprint_sensitivity = optional(number)
      ip_sensitivity          = optional(number)
      mode                    = optional(string, "Challenge")
      request_integrity       = optional(number)
    }))
    bot_categorization = optional(list(object({
      category = string
      action   = string
      overrides = optional(list(object({
        bot    = string
        action = string
      })))
    })))
    access_list = optional(set(object({
      action = string
      id     = number
    })), [])
  })
  default = {
    tier = "Advanced"
    ddos = {
      level = "Low"
    }
    waf = {
      enabled = true
      mode    = "Block"
    }
    bot_detection = {
      mode = "Challenge"
    }
  }
  description = <<DESCRIPTION
  Optional: Custom configuration for the Bunny pull zone shield, defaults will be used for values not supplied.
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_shield
  DESCRIPTION

  validation {
    error_message = "bunny_cdn_enablement must not be 'no' if bunny_pullzone_shield_config is set."
    condition     = length(keys(var.bunny_pullzone_shield_config)) > 0 && !alltrue([for v in values(var.bunny_pullzone_shield_config) : v == null]) ? var.bunny_cdn_enablement != "no" : true
  }
}

variable "bunny_pullzone_custom_waf_rules" {
  type = map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator       = string
      value          = string
      variable       = string
      variable_value = optional(string)
    }))
    response = object({
      action = string
    })
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Pull zone shield waf rules to apply.
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_waf_rule
  DESCRIPTION
}

variable "bunny_pullzone_base_rate_limit_rule" {
  type = object({
    enabled                = optional(bool, true)
    requests_per_second    = optional(number)
    block_duration_seconds = optional(number)
  })
  default     = {}
  description = "Values for the base rate limit configuration for the Bunny pull zone shield"
}

variable "bunny_pullzone_additional_rate_limit_rules" {
  type = map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator       = string
      value          = string
      variable       = string
      variable_value = optional(string)
    }))
    limit = object({
      requests = number
      interval = optional(number, 1)
    })
    response = object({
      interval = optional(number, 60)
    })
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Pull zone shield rate limit rules to apply.
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_ratelimit_rule
  DESCRIPTION
}

variable "bunny_pullzone_custom_access_lists" {
  type = map(object({
    name    = string
    action  = string
    type    = string
    entries = set(string)
    enabled = optional(bool, true)
  }))
  default     = {}
  description = <<DESCRIPTION
  Optional: Access lists to apply to the Bunny pull zone.
  Merged after built-in access lists, including the Ubiq secure gateway IP Shield bypass list (ubiq_secure_access_gateways).
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_access_list
  DESCRIPTION
}

variable "google_bot_bypass_enabled" {
  type        = bool
  default     = true
  description = "Whether to add a Bunny access list that bypasses the shield for Google user-triggered fetcher IP ranges"
}

variable "semrush_bot_bypass_enabled" {
  type        = bool
  default     = true
  description = "Whether to add a Bunny access list that bypasses the shield for Semrush IP ranges"
}

variable "web_app_x_azure_fdid_lockdown" {
  type        = bool
  default     = true
  description = "If enabled, the web app will accept traffic only from the Bunny CDN/WAF and remote access subnets"

  validation {
    condition     = var.web_app_x_azure_fdid_lockdown ? var.bunny_cdn_enablement == "yes" : true
    error_message = "web_app_x_azure_fdid_lockdown can only be enabled if bunny_cdn_enablement is 'yes'."
  }
}

variable "bot_detection_disable_paths" {
  type        = list(string)
  default     = []
  description = "A list of URL paths to disable Bunny bot detection"
}

variable "waf_rules_disable_paths" {
  type        = list(string)
  default     = []
  description = "A list of URL paths to disable Bunny WAF rules"
}

variable "web_app_os" {
  type        = string
  default     = "Windows"
  description = "The operating system of the web app, either Windows or Linux"

  validation {
    condition     = can(regex("^(Windows|Linux)$", var.web_app_os))
    error_message = "The web_app_os must be either Windows or Linux."
  }
}

variable "syslog_token" {
  type        = string
  sensitive   = true
  default     = null
  description = "Value for the Bunny syslog token"
}

variable "ubiq_shortener_api_key_selection" {
  type        = string
  default     = "primary"
  description = "Selection for the Ubiq shortener API key, should be either 'primary' or 'secondary'"

  validation {
    condition     = can(regex("^(primary|secondary)$", var.ubiq_shortener_api_key_selection))
    error_message = "The ubiq_shortener_api_key_selection must be either 'primary' or 'secondary'."
  }
}

variable "ubiq_captcha_admin_key_selection" {
  type        = string
  default     = "primary"
  description = "Selection for the Ubiq captcha service admin key, should be either 'primary' or 'secondary'"

  validation {
    condition     = can(regex("^(primary|secondary)$", var.ubiq_captcha_admin_key_selection))
    error_message = <<DESCRIPTION
    The ubiq_captcha_admin_key_selection must be either 'primary' or 'secondary'.
    This is used by Terraform only and applies to both prod and staging captcha environments.
    DESCRIPTION
  }
}

variable "captcha_site_key_rotation_increment" {
  type        = number
  default     = 0
  description = <<DESCRIPTION
  Keep at 0 during initial provisioning; then monotonically increment by exactly one to rotate the site's captcha
  site key. The previous key stays valid until the next rotation, so don't rotate twice inside the web app's Key Vault
  reference refresh window. Never decrease or reuse a prior value. If it is reset to 0 by mistake the stored key
  reverts to the original registration key, which is no longer valid: set any value of 1 or more to rotate again.
  DESCRIPTION

  validation {
    condition     = var.captcha_site_key_rotation_increment >= 0 && floor(var.captcha_site_key_rotation_increment) == var.captcha_site_key_rotation_increment
    error_message = "The captcha_site_key_rotation_increment must be a non-negative whole number."
  }
}

variable "ubiq_sendgrid_events_admin_key_selection" {
  type        = string
  default     = "primary"
  description = "Selection for the Ubiq SendGrid event receiver admin key, should be either 'primary' or 'secondary'"

  validation {
    condition     = can(regex("^(primary|secondary)$", var.ubiq_sendgrid_events_admin_key_selection))
    error_message = <<DESCRIPTION
    The ubiq_sendgrid_events_admin_key_selection must be either 'primary' or 'secondary'.
    This is used by Terraform only and applies to both prod and staging SendGrid receiver environments.
    DESCRIPTION
  }
}

variable "sendgrid_events_site_key_rotation_increment" {
  type        = number
  default     = 0
  description = <<DESCRIPTION
  Keep at 0 during initial registration; then monotonically increment by exactly one to rotate the site's SendGrid
  event receiver site key. The previous key stays valid until the next rotation. Never decrease or reuse a prior value.
  If it is reset to 0 by mistake the stored key reverts to the original registration key, which is no longer valid:
  set any value of 1 or more to rotate again.
  DESCRIPTION

  validation {
    condition     = var.sendgrid_events_site_key_rotation_increment >= 0 && floor(var.sendgrid_events_site_key_rotation_increment) == var.sendgrid_events_site_key_rotation_increment
    error_message = "The sendgrid_events_site_key_rotation_increment must be a non-negative whole number."
  }
}

variable "onboard_client_assets" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  Onboard the site to Client Assets when it is created: queues the Client Assets onboarding pipeline, which creates the
  site's asset repository (named after site_name), its pipelines and branch policies. It runs only when Terraform
  creates the site's AMAISSites entity (a new site, or a change of site key), never on update, and the apply does not
  wait for it. Set to false to skip onboarding. Turning it on or off for an existing site changes nothing.
  DESCRIPTION
}
