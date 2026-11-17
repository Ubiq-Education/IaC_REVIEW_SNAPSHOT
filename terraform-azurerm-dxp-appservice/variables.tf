variable "sub_id" {
  type        = string
  default     = "c94f8a3d-8d0b-4660-85de-26004f233dbf"
  description = "The guid id of the subscription in which to deploy this site."
}

variable "az_long_region" {
  type        = string
  default     = "uksouth"
  description = "Azure region name, e.g eastus, southcentralus, uksouth, etc."
}

variable "resource_group_name" {
  type        = string
  default     = "Amais-DXP"
  description = "The name of the resource group in which to deploy this site."
}

variable "dxp_vnet_alias" {
  type        = string
  default     = "dxp-01"
  description = "The alias for the DXP virtual network"

  validation {
    # should be one of a list of items
    condition     = can(regex("^(dxp-01)$", var.dxp_vnet_alias))
    error_message = "Allowed values for dxp_vnet_alias are: dxp-01."
  }
}

variable "webapp_name" {
  type        = string
  description = "The base name to use for the web app."
}

variable "do_not_format_app_name" {
  type        = bool
  default     = false
  description = "Do not format the app name."
}

variable "app_instance_count" {
  type        = number
  default     = 1
  description = "The number of instances to run for this site. Ignored if using autoscale rules."
}

variable "app_autoscale_rule_profiles" {
  type = map(object({
    name = string
    capacity = object({
      default = number
      maximum = number
      minimum = number
    })
    rules = optional(map(object({
      metric_trigger = object({
        metric_name        = string
        metric_resource_id = optional(string)
        operator           = string
        statistic          = string
        time_aggregation   = string
        time_grain         = string
        time_window        = string
        threshold          = number
        metric_namespace   = optional(string)
        dimensions = optional(map(object({
          name     = string
          operator = string
          values   = list(string)
        })))
        divide_by_instance_count = optional(bool)
      })
      scale_action = object({
        cooldown  = string
        direction = string
        type      = string
        value     = string
      })
    })))
    fixed_date = optional(object({
      end      = string
      start    = string
      timezone = optional(string, "UTC")
    }))
    recurrence = optional(object({
      timezone = optional(string, "UTC")
      days     = list(string)
      hours    = list(number)
      minutes  = list(number)
    }))
  }))
  default     = {}
  description = "Autoscale rule profiles to apply to the app service plan."

  validation {
    error_message = "use_existing_service_plan must be false if app_autoscale_rule_profiles are set."
    condition     = length(var.app_autoscale_rule_profiles) > 0 ? var.use_existing_service_plan == false : true
  }
}

variable "app_autoscale_rule_profiles_enabled" {
  type        = bool
  default     = true
  description = "Enable/disable the autoscale rule profiles."
}

variable "app_autoscale_name_override" {
  type        = string
  default     = null
  description = "Manually specifiy the name of the autoscale setting. If not set, a name will be generated."
}

variable "app_autoscale_rule_profiles_notification" {
  type = object({
    email = optional(object({
      send_to_subscription_administrator    = optional(bool, false)
      send_to_subscription_co_administrator = optional(bool, false)
      custom_emails                         = optional(list(string), [])
    }))
    webhooks = optional(map(object({
      service_uri = string
      properties  = optional(map(string), {})
    })))
  })
  default     = null
  description = <<DESCRIPTION
  (Optional) A notification block associated to autoscale setting. Defaults to null.
  - `email` - (Optional) A email block as defined below.
    - `send_to_subscription_administrator` - (Optional) Should email notifications be sent to the subscription administrator? Defaults to false.
    - `send_to_subscription_co_administrator` - (Optional) Should email notifications be sent to the subscription co-administrator? Defaults to false.
    - `custom_emails` - (Optional) Specifies a list of custom email addresses to which the email notifications will be sent.
  - `webhook` - (Optional) One or more webhook blocks as defined below.
    - `service_uri` - (Required) The HTTPS URI which should receive scale notifications.
    - `properties` - (Optional) A map of settings.
  DESCRIPTION
}

variable "app_stack_dotnet_version_production" {
  type        = string
  default     = "v8.0"
  description = "The version of the .NET stack to use for this site."
}

variable "app_stack_dotnet_version_staging" {
  type        = string
  default     = "v8.0"
  description = "The version of the .NET stack to use for this site."
}

variable "use_existing_service_plan" {
  type        = bool
  default     = false
  description = "Use an existing app service plan for this site."
}

variable "service_plan_name_override" {
  type        = string
  default     = null
  description = "Optional: The name of the service plan to use for this site."

  # validate that service_plan_name_override is set if use_existing_service_plan is true
  validation {
    condition     = var.use_existing_service_plan == true ? var.service_plan_name_override != null : true
    error_message = "service_plan_name_override must be set if use_existing_service_plan is true."
  }
}

variable "service_plan_sku" {
  type        = string
  default     = "P0v3"
  description = "The SKU of the service plan to use for this site."
}

variable "mapped_storage_accounts" {
  type = list(object({
    type                   = string
    name                   = string
    account_name           = string
    storage_resource_group = string
    share_name             = string
    mount_path             = string
  }))
  default     = null
  description = "List of storage account configurations"

  validation {
    condition = var.mapped_storage_accounts != null ? alltrue([
      for sa in var.mapped_storage_accounts : sa.type == "AzureFiles" || sa.type == "AzureBlob"
    ]) : true
    error_message = "Allowed storage types are AzureFiles or AzureBlob."
  }
  validation {
    condition     = var.mapped_storage_accounts != null ? length(var.mapped_storage_accounts) <= 5 : true
    error_message = "A maximum of 5 storage accounts can be mapped."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to all resources."
}

variable "auth0_oauth_settings_enabled_staging" {
  type        = bool
  default     = false
  description = "Enable Auth0 OAuth settings on the staging slot."
}

variable "auth0_oauth_settings_enabled_production" {
  type        = bool
  default     = false
  description = "Enable Auth0 OAuth settings on the production slot."

}

variable "db_connection_sql_server_fqdn" {
  type        = string
  default     = "amais-dxp.database.windows.net"
  description = <<DESCRIPTION
  The fqdn of the Azure SQL Server to connect to
  Expects logging databases with names: AMAIS-DXP-LOGGING and AMAIS-DXP-STAGING-LOGGING.
  DESCRIPTION
}

variable "db_connection_sql_db_name" {
  type        = string
  default     = "AMAIS-DXP-MD"
  description = "The name of the Azure SQL database to connect to."
}

variable "db_connection_sql_db_name_max_pool_size" {
  type        = number
  default     = 1200
  description = "The max pool size for the SQL database connection string."
}

variable "db_connection_sql_db_name_staging_override" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  The name of the Azure SQL database to connect to on the staging slot.
  If not set, '-STAGING' will be appended to the db_connection_sql_db_name.
  DESCRIPTION
}

variable "db_connection_sql_db_name_max_pool_size_staging" {
  type        = number
  default     = 200
  description = "The max pool size for the staging SQL database connection string."
}

variable "db_connection_use_entra_auth_staging" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  Use Entra authentication for the SQL connection on the staging slot. If false, use the default credentials retrieved from the key vault.
  DESCRIPTION
}

variable "db_connection_use_entra_auth_production" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  Use Entra authentication for the SQL connection on the production slot. If false, use the default credentials retrieved from the key vault.
  DESCRIPTION
}

variable "app_slots" {
  type = map(object({
    app_settings_base_slot   = optional(string)
    app_settings             = map(string)
    app_stack_dotnet_version = optional(string, "v10.0")
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of slots and additional app settinngs for the web app.
  App settings should be a map of key-value pairs, these will be merged with the default settings.
  The settings supplied to the variable will override the default settings if a key name matches.

  ```terraform
  app_slots = {
    production = {
      app_settings = {
        Application = "AMAIS_DXP_ANALYTICS"
      }
    }
    staging = {
      app_settings = {
        Application = "AMAIS_DXP_ANALYTICS"
      }
    }
    prod2 = {
    app_settings_base_slot = "production"
      app_settings = {
        Application = "AMAIS_DXP_ANALYTICS"
      }
    }
  }
  ```
  DESCRIPTION
  validation {
    condition = alltrue([
      for k, v in var.app_slots :
      v.app_settings_base_slot != null ? contains(["production", "staging"], v.app_settings_base_slot) : true
    ])
    error_message = "The app_settings_base_slot value must be either 'production', 'staging', or null."
  }
}

variable "dxp_ingress_eventhub_namespace_name" {
  type        = string
  default     = "amais-dxp-ingress"
  description = "The name of the dxp-ingress event hub namespace where any eventhub instances can be found."

}

variable "health_check_enabled" {
  type        = bool
  default     = true
  description = "Enable the health check endpoint for the web app."
}

variable "health_check_path" {
  type        = string
  default     = "/api/v1/healthcheck"
  description = "The path to the health check endpoint for the web app. Default if not set is /api/v1/healthcheck"

  validation {
    condition     = substr(var.health_check_path, 0, 1) == "/"
    error_message = "health_check_path must start with a forward slash."
  }
}

variable "health_check_eviction_time_in_min" {
  type        = number
  default     = 10
  description = "The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10."

  validation {
    condition     = var.health_check_eviction_time_in_min >= 2 && var.health_check_eviction_time_in_min <= 10
    error_message = "health_check_eviction_time_in_min must be between 2 and 10."
  }
}

variable "elastic_search_settings_enabled" {
  type        = bool
  default     = false
  description = "Enable Elastic Search settings."
}

variable "elastic_search_tenant_data_stream_slot" {
  type        = string
  default     = "production"
  description = "The slot to use for the tenant data stream."

  validation {
    condition     = can(regex("^(production|staging)$", var.elastic_search_tenant_data_stream_slot))
    error_message = "elastic_search_tenant_data_stream_slot must be either 'production' or 'staging'."
  }
}

variable "analytics_db_connection_enabled_production" {
  type        = bool
  default     = false
  description = "Enable the analytics database connection string for the production slot."
}

variable "analytics_db_connection_sql_db_name_max_pool_size" {
  type        = number
  default     = 900
  description = "The max pool size for the analytics SQL database connection string."
}

variable "analytics_db_connection_enabled_staging" {
  type        = bool
  default     = false
  description = "Enable the analytics database connection string for the staging slot."
}

variable "analytics_db_connection_sql_db_name_max_pool_size_staging" {
  type        = number
  default     = 200
  description = "The max pool size for the staging analytics SQL database connection string."
}

variable "add_global_cosmos_db_connection_info" {
  type        = bool
  default     = false
  description = "Add the global DXP cosmos db connection info to the app settings."
}

variable "client_affinity_enabled" {
  type        = bool
  default     = false
  description = "Enable client affinity for the web app."

}

variable "dxp_redis_cache_enabled" {
  type        = bool
  default     = false
  description = "Add the DXP Redis cache environment variables for the web app."
}

variable "analytics_service_connection_enabled_staging" {
  type        = bool
  default     = false
  description = "Add the analytics service connection environment variables for the web app staging slot."
}

variable "analytics_service_connection_enabled_production" {
  type        = bool
  default     = false
  description = "Add the analytics service connection environment variables for the web app production slot."
}

variable "ingress_service_connection_enabled_staging" {
  type        = bool
  default     = false
  description = "Add the ingress service connection environment variables for the web app staging slot."
}

variable "ingress_service_connection_enabled_production" {
  type        = bool
  default     = false
  description = "Add the ingress service connection environment variables for the web app production slot."
}

variable "notification_service_connection_enabled_staging" {
  type        = bool
  default     = false
  description = "Add the notification service connection environment variables for the web app staging slot."
}

variable "notification_service_connection_enabled_production" {
  type        = bool
  default     = false
  description = "Add the notification service connection environment variables for the web app production slot."
}

variable "report_service_connection_enabled_staging" {
  type        = bool
  default     = false
  description = "Add the report service connection environment variables for the web app staging slot."
}

variable "report_service_connection_enabled_production" {
  type        = bool
  default     = false
  description = "Add the report service connection environment variables for the web app production slot."
}

variable "mi_dxp_api_roles_staging" {
  type        = list(string)
  default     = []
  description = "Entra roles to assign to the web app managed identity. The roles will be assigned on the API envionment matching the staging slot"
}

variable "mi_dxp_api_roles_production" {
  type        = list(string)
  default     = []
  description = "Entra roles to assign to the web app managed identity. The roles will be assigned on the API envionment matching the production slot."
}

variable "distilled_connection_enabled_staging" {
  type        = bool
  default     = false
  description = "Enable the distilled connection string for the staging slot."
}

variable "distilled_connection_enabled_production" {
  type        = bool
  default     = false
  description = "Enable the distilled connection string for the production slot."
}

variable "distilled_location" {
  type        = string
  default     = "s3://queries.external.337909766656.us-east-1"
  description = "The location for the distilled service (DistilledSettings__Location)."
}

variable "distilled_workgroup" {
  type        = string
  default     = "DistilledResolutions"
  description = "The workgroup for the distilled service (DistilledSettings__WorkGroup)."

}

variable "app_identity_roles_production" {
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default     = {}
  description = "List of additional roles to assign to the app production identity"
}

variable "app_identity_roles_staging" {
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default     = {}
  description = "List of additional roles to assign to the app staging identity"
}

#TODO: Add the configuration to use this variable
variable "waf_azure_fdid_lockdown" {
  type = object({
    x_azure_fdid_value = string
    production         = optional(bool, true)
    staging            = optional(bool, true)
    others             = optional(bool, true)
  })
  default     = null
  description = "value for the X-Azure-FDID header to restrict the web app slots to only be accessible via the WAF. Plus which slots to apply ip restrictions to."
}

variable "redis_cache_enabled" {
  type        = bool
  default     = true
  description = "Whether to add the DXP Redis cache environment variables for the web app and add access for the managed identity to the Redis cache instance."
}
