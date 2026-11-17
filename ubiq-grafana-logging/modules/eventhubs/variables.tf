variable "eventhub_namespace_name" {
  type        = string
  description = "Value for the event hub namespace name"
}

variable "az_long_region" {
  type        = string
  description = "Value for the long region name"
}

variable "resource_group_name" {
  type        = string
  description = "Value for the resource group name"
}

variable "eventhub_namespace_sku" {
  type        = string
  default     = "Standard"
  description = "Value for the event hub namespace SKU"
}

variable "eventhub_namespace_capacity" {
  type        = number
  default     = 1
  description = "Value for the event hub namespace capacity"
}

variable "eventhub_namespace_minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Value for the event hub namespace minimum TLS version"
}

variable "event_hubs" {
  type = map(object({
    status                            = string
    partition_count                   = number
    consumer_groups                   = optional(list(string), [])
    data_sender_principal_ids         = optional(list(string), [])
    data_receiver_principal_ids       = optional(list(string), [])
    cleanup_policy                    = optional(string, "Delete")
    retention_time_in_hours           = optional(number)
    tombstone_retention_time_in_hours = optional(number)
  }))
  description = "Event Hubs configuration"
}

variable "eventhub_namespace_allowed_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs that are allowed to access the Event Hub Namespace when network rules are configured."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to the resources"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
}

