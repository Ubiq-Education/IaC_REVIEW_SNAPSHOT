variable "az_long_region" {
  description = "The Azure region to deploy the resources to"
  type        = string

  validation {
    condition     = contains(local.dxp_regions, var.az_long_region)
    error_message = "The az_long_region variable must be one of the following: ${join(", ", local.dxp_regions)}"
  }
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the resources to"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources"
  type        = map(string)
}

variable "cosmosdb_data_classifcation" {
  description = "The data classification tag value for the CosmosDB account"
  type        = string
}

variable "add_delete_locks" {
  description = "Whether to add delete locks to the resources"
  type        = bool
  default     = true
}

variable "cosmosdb_data_usage_alert_threshold_bytes" {
  description = "The threshold in bytes for the CosmosDB data usage alert"
  type        = number
  default     = 107374182400
}
