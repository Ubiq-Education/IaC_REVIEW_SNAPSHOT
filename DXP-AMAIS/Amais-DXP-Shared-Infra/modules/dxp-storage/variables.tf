variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID to deploy the resources to"
}

variable "az_long_region" {
  type        = string
  description = "The Azure region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy the resources to"
}

variable "add_delete_locks" {
  type        = bool
  default     = true
  description = "Whether to add delete locks to the resources"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to the resources"
}

variable "staging_role_assignments" {
  type = map(object({
    principal_id = string
    role_name    = string
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to apply to the staging resources for support or development teams.
  Resource role assigments should be applied by the source/consuming resource deployment.

  Example:
  {
    "support-role-1" = {
      principal_id = "00000000-0000-0000-0000-000000000000"
      role_name    = "Contributor"
    }
    "support-role-2" = {
      principal_id = "00000000-0000-0000-0000-000000000000"
      role_name    = "Reader"
    }
  }
  DESCRIPTION
}

variable "production_role_assignments" {
  type = map(object({
    principal_id = string
    role_name    = string
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to apply to the production resources for support or development teams.
  Resource role assigments should be applied by the source/consuming resource deployment.

  Example:
  {
    "support-role-1" = {
      principal_id = "00000000-0000-0000-0000-000000000000"
      role_name    = "Contributor"
    }
    "support-role-2" = {
      principal_id = "00000000-0000-0000-0000-000000000000"
      role_name    = "Reader"
    }
  }
  DESCRIPTION
}

variable "storage_purpose_short_name" {
  type        = string
  description = "The short name of the storage account purpose. Maximum of 12 lowercase letters and numbers."

  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.storage_purpose_short_name))
    error_message = "The storage purpose short name must be a maximum of 12 lowercase letters and numbers."
  }
}

variable "blob_delete_retention_policy" {
  type = object({
    days                     = any
    permanent_delete_enabled = optional(bool, false)
  })
  default = {
    days = null
  }
  description = "The blob delete retention policy to apply to the storage account. Set to null to disable."

  validation {
    condition     = var.blob_delete_retention_policy.days == null || can(var.blob_delete_retention_policy.days + 0)
    error_message = "The 'days' attribute must be either a number or null."
  }
}

variable "blob_versioning_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable blob versioning on the storage account"
}


variable "network_rules_bypass_azure_services" {
  type        = bool
  default     = true
  description = "Whether to bypass Azure services for network rules"
}

variable "network_rules_default_action" {
  type        = string
  default     = "Deny"
  description = "The default action for network rules. Can be 'Allow' or 'Deny'."

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules_default_action)
    error_message = "The default action for network rules must be 'Allow' or 'Deny'."
  }
}

variable "network_rules_ip_rules" {
  type        = set(string)
  default     = []
  description = "A set of IP rules to apply to the network rules. Can be a list of CIDR ranges or individual IP addresses."
}

variable "network_rules_virtual_network_subnet_ids" {
  type        = set(string)
  default     = []
  description = "A set of virtual network subnet IDs to apply to the network rules."
}
