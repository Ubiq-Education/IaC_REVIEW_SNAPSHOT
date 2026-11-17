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

variable "diagnostics_settings_name" {
  type        = string
  default     = "ubiq_diagnostic_settings"
  description = "The name of the diagnostics settings. Optional, if not provided, a default name will be used."
}

variable "diagnostics_destinations" {

  type = object({
    log_analytics = optional(object({
      enabled = bool
      workspace_id = optional(string,
        "/subscriptions/c94f8a3d-8d0b-4660-85de-26004f233dbf/resourceGroups/rg-uks-ubiq-shared-logging/providers/Microsoft.OperationalInsights/workspaces/log-uks-ubiq-shared-logging"
      )
    }))
    event_hub = optional(object({
      enabled                   = bool
      eventhub_namespace_id     = string # TODO: Create new helper module to output all central Ubiq resources that root modules can use to supply this sort of info
      eventhub_name             = optional(string, "evh-logevents")
      shared_access_policy_name = optional(string, "SendEvents")
    }))
    storage_account = optional(object({
      enabled            = bool
      storage_account_id = string
    }))
  })
  description = <<-DESCRIPTION
  The destinations to send diagnostics data to. Each destination has an 'enabled' property to indicate whether it should be used,
  and additional properties as required for that destination type.
  DESCRIPTION

  validation {
    error_message = "At least one destination must be enabled"
    condition = (
      try(var.diagnostics_destinations.log_analytics.enabled, false) ||
      try(var.diagnostics_destinations.event_hub.enabled, false) ||
      try(var.diagnostics_destinations.storage_account.enabled, false)
    )
  }

  validation {
    error_message = "eventhub_namespace_id must of the correct resource type if event hub destination is enabled"
    condition = (
      try(var.diagnostics_destinations.event_hub.enabled, false) ?
      can(provider::azurerm::parse_resource_id(var.diagnostics_destinations.event_hub.eventhub_namespace_id)) &&
      provider::azurerm::parse_resource_id(var.diagnostics_destinations.event_hub.eventhub_namespace_id)["full_resource_type"] == "Microsoft.EventHub/namespaces" :
      true
    )
  }
}

variable "enabled_log_categories" {
  type        = list(string)
  default     = []
  description = <<-DESCRIPTION
  List of log categories to enable in the diagnostics settings. Either enabled_log_categories or enabled_log_category_groups can be used, but not both.
  If neither are provided, "allLogs" and "audit" category groups will be enabled by default.
  DESCRIPTION

  validation {
    error_message = "enabled_log_categories and enabled_log_category_groups are mutually exclusive — only one can be specified."
    condition     = !(length(var.enabled_log_categories) > 0 && length(var.enabled_log_category_groups) > 0)
  }

  validation {
    error_message = "List must not contain duplicates"
    condition     = length(distinct(var.enabled_log_categories)) == length(var.enabled_log_categories)
  }
}

variable "enabled_log_category_groups" {
  type        = list(string)
  default     = []
  description = <<-DESCRIPTION
  List of log category groups to enable in the diagnostics settings. Either enabled_log_categories or enabled_log_category_groups can be used, but not both.
  If neither are provided, "allLogs" and "audit" category groups will be enabled by default.
  DESCRIPTION

  validation {
    error_message = "List must not contain duplicates"
    condition     = length(distinct(var.enabled_log_category_groups)) == length(var.enabled_log_category_groups)
  }
}

variable "enabled_metrics" {
  type        = list(string)
  default     = []
  description = "List of metric categories to enable in the diagnostics settings."

  validation {
    error_message = "List must not contain duplicates"
    condition     = length(distinct(var.enabled_metrics)) == length(var.enabled_metrics)
  }
}

variable "diagnostics_resource_ids" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
  Map of Azure resource id's for standard diagnostic settings and audit configurations.
  Storage accounts should be supplied using the diagnostics_storage_resource_ids variable instead.
  DESCRIPTION

  validation {
    error_message = <<-DESCRIPTION
    Each value must be a valid resource id as parsed by provider::azurerm::parse_resource_id()".
    Note: Certain resource types such as storage account blobServices, queueServices, tableServices, and fileServices have unsupported resource ids,
    for storage account services user the diagnostics_storage_resource_ids variable.
    DESCRIPTION
    condition = alltrue([
      for id in values(var.diagnostics_resource_ids) :
      anytrue([for s in local.unparseable_resource_id_segments : strcontains(id, s)]) ?
      false : can(provider::azurerm::parse_resource_id(id))
    ])
  }

  validation {
    error_message = "Map values must not contain duplicate id's"
    condition     = length(distinct(values(var.diagnostics_resource_ids))) == length(values(var.diagnostics_resource_ids))
  }
}

variable "diagnostics_storage_resource_ids" {
  type = map(object({
    id            = string
    blob_enabled  = optional(bool, true)
    queue_enabled = optional(bool, true)
    table_enabled = optional(bool, true)
    file_enabled  = optional(bool, true)
  }))
  default     = {}
  description = "Storage accounts which to add diagnostic settings and the services to log, by default all services will have diagnostics added."

  validation {
    error_message = "Map values must not contain duplicate id's"
    condition     = length(distinct([for v in values(var.diagnostics_storage_resource_ids) : v.id])) == length(values(var.diagnostics_storage_resource_ids))
  }

  validation {
    error_message = "Each id must be a valid resource id as parsed by provider::azurerm::parse_resource_id() and of the correct resource type"
    condition = alltrue([
      for v in values(var.diagnostics_storage_resource_ids) :
      can(provider::azurerm::parse_resource_id(v.id)) &&
      provider::azurerm::parse_resource_id(v.id)["full_resource_type"] == "Microsoft.Storage/storageAccounts"
    ])
  }
}

variable "mssql" {
  type = object({
    mssql_server_auditing_enabled                   = optional(bool, false)
    mssql_server_microsoft_support_auditing_enabled = optional(bool, false)
    mssql_database_auditing_enabled                 = optional(bool, false)
    auditing_retention_in_days                      = optional(number, 90)
    auditing_storage_account_id                     = optional(string)
    mssql_server_ids                                = optional(map(string), {})
    mssql_database_ids                              = optional(map(string), {})
    resource_metric_alerts_enabled                  = optional(bool, true)
    alerts_action_group                             = optional(string, "warning")
    mssql_location                                  = optional(string)
  })
  default     = {}
  description = "Configures Azure SQL and Azure SQL DB advanced auditing to send audit logs to a specified storage account."

  validation {
    error_message = "auditing_storage_account_id must be provided if either any mssql_server_ids or mssql_database_ids are provided"
    condition = (
      (length(var.mssql.mssql_server_ids) > 0 || length(var.mssql.mssql_database_ids) > 0) ?
      var.mssql.auditing_storage_account_id != null && length(var.mssql.auditing_storage_account_id) > 0 : true
    )
  }

  validation {
    error_message = "mssql_server_ids must be provided if mssql_server_auditing_enabled is true"
    condition = (
      var.mssql.mssql_server_auditing_enabled ? length(var.mssql.mssql_server_ids) > 0 : true
    )
  }

  validation {
    error_message = "mssql_server_ids must be provided if mssql_server_microsoft_support_auditing_enabled is true"
    condition = (
      var.mssql.mssql_server_microsoft_support_auditing_enabled ? length(var.mssql.mssql_server_ids) > 0 : true
    )
  }

  validation {
    error_message = "mssql_database_ids must be provided if mssql_database_auditing_enabled is true"
    condition = (
      var.mssql.mssql_database_auditing_enabled ? length(var.mssql.mssql_database_ids) > 0 : true
    )
  }

  validation {
    error_message = "mssql_server_ids must be in the format of a resource id"
    condition = alltrue([
      for k, id in var.mssql.mssql_server_ids : can(provider::azurerm::parse_resource_id(id))
    ])
  }

  validation {
    error_message = "mssql_database_ids must be in the format of a resource id"
    condition = alltrue([
      for k, id in var.mssql.mssql_database_ids : can(provider::azurerm::parse_resource_id(id))
    ])
  }

  validation {
    error_message = "auditing_storage_account_id must be in the format of a resource id"
    condition = (
      # This ternary matches the count condition for the azurerm_storage_account.sql_auditing data source
      # ensuring that if a storage account id is provided, it must be parseable as a resource id
      var.mssql.auditing_storage_account_id != null ?
      can(provider::azurerm::parse_resource_id(var.mssql.auditing_storage_account_id)) : true
    )
  }

  validation {
    error_message = "alerts_action_group must be one of 'warning', 'global', or 'critical'"
    condition     = contains(keys(local.action_group_ids), var.mssql.alerts_action_group)
  }

  validation {
    error_message = "mssql_location must be provided if mssql_server_ids or mssql_database_ids are provided"
    condition = (
      (length(var.mssql.mssql_server_ids) > 0 || length(var.mssql.mssql_database_ids) > 0) ?
      var.mssql.mssql_location != null && length(var.mssql.mssql_location) > 0 : true
    )
  }
}

variable "web_app" {
  type = object({
    resource_ids                     = optional(map(string), {})
    response_time_alert_enabled      = optional(bool, true)
    server_errors_alert_enabled      = optional(bool, true)
    health_check_alert_enabled       = optional(bool, true)
    response_time_alert_action_group = optional(string, "global")
    server_errors_alert_action_group = optional(string, "global")
    health_check_alert_action_group  = optional(string, "critical")
  })
  default     = {}
  description = "Configures Azure Monitor metric alerts for Azure Web Apps. Alerts will be created for each resource id provided in resource_ids."

  validation {
    error_message = "Each resource id must be in the format of a resource id and of the correct resource type"
    condition = alltrue([
      for k, id in var.web_app.resource_ids :
      can(provider::azurerm::parse_resource_id(id)) &&
      provider::azurerm::parse_resource_id(id)["full_resource_type"] == "Microsoft.Web/sites"
    ])
  }

  validation {
    error_message = "action groups must be one of 'warning', 'global', or 'critical'"
    condition = alltrue([
      contains(keys(local.action_group_ids), var.web_app.response_time_alert_action_group) &&
      contains(keys(local.action_group_ids), var.web_app.server_errors_alert_action_group) &&
      contains(keys(local.action_group_ids), var.web_app.health_check_alert_action_group)
    ])
  }
}

variable "function_apps" {
  type = map(object({
    location                      = string
    resource_id                   = string
    insights_resource_id          = string
    max_failures_alert_enabled    = optional(bool, true)
    max_failures_threshold        = optional(number, 1)
    max_failures_window           = optional(string, "PT30M")
    max_inactivity_alert_enabled  = optional(bool, true)
    max_inactivity_window         = optional(string, "P1D")
    failure_alert_action_group    = optional(string, "warning")
    inactivity_alert_action_group = optional(string, "warning")
  }))
  default     = {}
  description = "Map of function app resource ids to configuration for function app specific alerts."

  validation {
    error_message = "Windows must be in ISO 8601 duration format"
    condition = alltrue([
      for i in values(var.function_apps) :
      can(regex("^(-?)P(?:\\d+W|(?:\\d+Y(?:\\d+M)?(?:\\d+D)?|\\d+M(?:\\d+D)?|\\d+D)(?:T(?:\\d+H(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?|\\d+M(?:\\d+(?:\\.\\d+)?S)?|\\d+(?:\\.\\d+)?S))?|T(?:\\d+H(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?|\\d+M(?:\\d+(?:\\.\\d+)?S)?|\\d+(?:\\.\\d+)?S))$", i.max_failures_window)) &&
      can(regex("^(-?)P(?:\\d+W|(?:\\d+Y(?:\\d+M)?(?:\\d+D)?|\\d+M(?:\\d+D)?|\\d+D)(?:T(?:\\d+H(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?|\\d+M(?:\\d+(?:\\.\\d+)?S)?|\\d+(?:\\.\\d+)?S))?|T(?:\\d+H(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?|\\d+M(?:\\d+(?:\\.\\d+)?S)?|\\d+(?:\\.\\d+)?S))$", i.max_inactivity_window))
    ])
  }

  validation {
    error_message = "action groups must be one of 'warning', 'global', or 'critical'"
    condition = alltrue([
      for i in values(var.function_apps) :
      contains(keys(local.action_group_ids), i.failure_alert_action_group) &&
      contains(keys(local.action_group_ids), i.inactivity_alert_action_group)
    ])
  }

  validation {
    error_message = "Each resource_id and insights_resource_id must of the correct resource type"
    condition = alltrue([
      for i in values(var.function_apps) :
      provider::azurerm::parse_resource_id(i.resource_id)["full_resource_type"] == "Microsoft.Web/sites" &&
      provider::azurerm::parse_resource_id(i.insights_resource_id)["full_resource_type"] == "Microsoft.Insights/components"
    ])
  }
}

variable "traffic_manager_profiles" {
  type = map(object({
    resource_id                     = string
    check_window                    = optional(string, "PT5M")
    endpoint_alert_action_group     = optional(string, "warning")
    all_endpoint_alert_action_group = optional(string, "critical")
  }))
  default     = {}
  description = "Map of Traffic Manager profile resource ids to configuration for Traffic Manager specific alerts."

  validation {
    error_message = "action groups must be one of 'warning', 'global', or 'critical'"
    condition = alltrue([
      for i in values(var.traffic_manager_profiles) :
      contains(keys(local.action_group_ids), i.endpoint_alert_action_group) &&
      contains(keys(local.action_group_ids), i.all_endpoint_alert_action_group)
    ])
  }

  validation {
    error_message = "Windows must be in ISO 8601 duration format"
    condition = alltrue([
      for i in values(var.traffic_manager_profiles) :
      can(regex("^(-?)P(?:\\d+W|(?:\\d+Y(?:\\d+M)?(?:\\d+D)?|\\d+M(?:\\d+D)?|\\d+D)(?:T(?:\\d+H(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?|\\d+M(?:\\d+(?:\\.\\d+)?S)?|\\d+(?:\\.\\d+)?S))?|T(?:\\d+H(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?|\\d+M(?:\\d+(?:\\.\\d+)?S)?|\\d+(?:\\.\\d+)?S))$", i.check_window))
    ])
  }

  validation {
    error_message = "Each resource_id must of the correct resource type"
    condition = alltrue([
      for i in values(var.traffic_manager_profiles) :
      provider::azurerm::parse_resource_id(i.resource_id)["full_resource_type"] == "Microsoft.Network/trafficManagerProfiles"
    ])
  }
}

variable "container_apps" {
  type = map(object({
    resource_id                           = string
    law_resource_id                       = string
    law_location                          = string
    replica_count_alert_enabled           = optional(bool, true)
    readiness_probe_failure_alert_enabled = optional(bool, true)
    replica_count_threshold               = optional(number, 100)
    readiness_probe_failure_threshold     = optional(number, 3)
    replica_count_action_group            = optional(string, "warning")
    readiness_probe_failure_action_group  = optional(string, "warning")
  }))
  default     = {}
  description = <<-DESCRIPTION
  Map of Container App resource ids to configuration for standard alerts.
  replica_count_threshold operator is GreaterThanOrEqual.
  DESCRIPTION

  validation {
    error_message = "action groups must be one of 'warning', 'global', or 'critical'"
    condition = alltrue([
      for i in values(var.container_apps) :
      contains(keys(local.action_group_ids), i.replica_count_action_group) &&
      contains(keys(local.action_group_ids), i.readiness_probe_failure_action_group)
    ])
  }

  validation {
    error_message = "Each resource_id and law_resource_id must of the correct resource type"
    condition = alltrue([
      for i in values(var.container_apps) :
      provider::azurerm::parse_resource_id(i.resource_id)["full_resource_type"] == "Microsoft.App/containerApps" &&
      provider::azurerm::parse_resource_id(i.law_resource_id)["full_resource_type"] == "Microsoft.OperationalInsights/workspaces"
    ])
  }
}

variable "nat_gateways" {
  type = map(object({
    resource_id         = string
    allocated_ips       = number
    snat_alert_enabled  = optional(bool, true)
    alerts_action_group = optional(string, "warning")
  }))
  default     = {}
  description = "Map of NAT Gateway resource ids to configuration for NAT Gateway specific alerts."

  validation {
    error_message = "Each resource_id must of the correct resource type"
    condition = alltrue([
      for i in values(var.nat_gateways) :
      provider::azurerm::parse_resource_id(i.resource_id)["full_resource_type"] == "Microsoft.Network/natGateways"
    ])
  }

  validation {
    error_message = "action groups must be one of 'warning', 'global', or 'critical'"
    condition = alltrue([
      for i in values(var.nat_gateways) :
      contains(keys(local.action_group_ids), i.alerts_action_group)
    ])
  }
}
