variable "environment" {
  type        = string
  description = <<DESCRIPTION
  The environment for which the resources are being created (e.g. staging, prod). Use in names and tags."
  Changing will result in resource recreation.
  DESCRIPTION
}

variable "regions_enabled" {
  type = map(object({
    custom_domain_and_cert_enabled = optional(bool, false)
    add_cae_cert_to_byo_cert_list  = optional(bool, false)
    maintenance_window = optional(object({
      durationHours = number
      startHourUtc  = number
      weekDay       = string
    }))
    redis_config = optional(object({
      sku_name = optional(string)
    }))
    signalr_config = optional(object({
      sku_name                                 = optional(string)
      sku_capacity                             = optional(number)
      serverless_connection_timeout_in_seconds = optional(number)
      custom_domain_and_cert_enabled           = optional(bool, false)
      custom_domain_fqdn                       = optional(string)
      key_vault_certificate_name               = optional(string)
    }))
    postgresql_config = optional(object({
      sku_name     = optional(string)
      storage_mb   = optional(number)
      storage_tier = optional(string)
      version      = optional(string)
      # cluster_size = optional(number) # Possible future use
      maintenance_window = optional(object({
        day_of_week  = number
        start_hour   = number
        start_minute = number
      }))
    }))
    otel_export_config = optional(object({
      alloy_export_enabled = optional(bool, false)
      alloy_grpc_endpoint  = string
    }))

  }))
  default     = {}
  description = <<DESCRIPTION
  Target regions to deploy the Wkflo environment with optional region-specific configuration. Keys should be the region names (e.g. "uksouth").

  If custom_domain_and_cert_enabled is true the config will lookup the key vault and certificate defined in this module using the CAE name as a basis.
  Certificate must already exist in the key vault - can be deployed using the platform certificates devops pipeline.

  IMPORTANT: Cannot be enabled at the time of CAE creation, so will require a two step deployment, first deploy with this set to false.
  Suggested order of operations for new environments
  1. Deploy region with custom_domain_and_cert_enabled set to false
  2. Add certificate to key vault (e.g. using devops pipeline)
  3. Set region custom_domain_and_cert_enabled to true and redeploy to apply the custom domain and certificate to the CAE.

  Above also applies to SignalR if custom_domain_and_cert_enabled is set under signalr_config, but note that for SignalR custom domain and cert is only supported on Premium SKU.
  DESCRIPTION

  validation {
    condition     = alltrue([for region, config in var.regions_enabled : contains(keys(local.cae_regions), region)])
    error_message = "All keys in regions_enabled must match a key in local.cae_regions, base regional config must be defined in local.cae_regions first"
  }

  validation {
    condition = alltrue([
      for region, config in var.regions_enabled :
      !coalesce(try(config.signalr_config.custom_domain_and_cert_enabled, null), false) || try((config.signalr_config.key_vault_certificate_name != null), false)
    ])
    error_message = "signalr_config.key_vault_certificate_name must be set if signalr_config.custom_domain_and_cert_enabled is true"
  }

  validation {
    condition = alltrue([
      for region, config in var.regions_enabled :
      !coalesce(try(config.signalr_config.custom_domain_and_cert_enabled, null), false) || try((config.signalr_config.custom_domain_fqdn != null), false)
    ])
    error_message = "signalr_config.custom_domain_fqdn must be set if signalr_config.custom_domain_and_cert_enabled is true"
  }

  validation {
    condition = alltrue([
      for region, config in var.regions_enabled :
      !coalesce(try(config.signalr_config.custom_domain_and_cert_enabled, null), false) || startswith(coalesce(try(config.signalr_config.sku_name, null), "Standard_S1"), "Premium_")
    ])
    error_message = "signalr_config.custom_domain_and_cert_enabled can only be true when signalr_config.sku_name starts with Premium_"
  }

  validation {
    error_message = "SignalR custom domain must be a subdomain of ${local.domain_suffix}"
    condition = alltrue([
      for region, config in var.regions_enabled :
      !coalesce(try(config.signalr_config.custom_domain_and_cert_enabled, null), false) || endswith(config.signalr_config.custom_domain_fqdn, ".${local.domain_suffix}")
    ])
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to the resources"
}

variable "wkflo_sql_db_sku_name" {
  type        = string
  default     = "S1"
  description = "SKU name for the WKFLO SQL database"
}

variable "wkflo_sql_db_max_size_gb" {
  type        = number
  default     = 50
  description = "Max size in GB for the WKFLO SQL database"
}

variable "add_delete_locks" {
  type        = bool
  default     = true
  description = "Whether to add delete locks to relevant resources"
}
