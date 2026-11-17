<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-monitoring-diagnostics

Module to help ensure standard monitoring, alerts and diagnostics configurations are deployed with resources.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~>1.11)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>=4.60)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>=4.60)

## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_monitor_metric_alert.ca_replica_count](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.func_app_inactivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.health_check](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.nat_gw_snat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.response_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.server_errors](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.sql_cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.sql_data_io](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.sql_disk_space](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.traffic_manager_endpoint_degraded](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_metric_alert.traffic_manager_profile_degraded](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) (resource)
- [azurerm_monitor_scheduled_query_rules_alert_v2.cae_readiness_probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) (resource)
- [azurerm_monitor_scheduled_query_rules_alert_v2.func_app_failures](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) (resource)
- [azurerm_mssql_database_extended_auditing_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) (resource)
- [azurerm_mssql_server_extended_auditing_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) (resource)
- [azurerm_mssql_server_microsoft_support_auditing_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_microsoft_support_auditing_policy) (resource)
- [azurerm_storage_account.sql_auditing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_diagnostics_destinations"></a> [diagnostics\_destinations](#input\_diagnostics\_destinations)

Description: The destinations to send diagnostics data to. Each destination has an 'enabled' property to indicate whether it should be used,  
and additional properties as required for that destination type.

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_container_apps"></a> [container\_apps](#input\_container\_apps)

Description: Map of Container App resource ids to configuration for standard alerts.  
replica\_count\_threshold operator is GreaterThanOrEqual.

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_diagnostics_resource_ids"></a> [diagnostics\_resource\_ids](#input\_diagnostics\_resource\_ids)

Description:   Map of Azure resource id's for standard diagnostic settings and audit configurations.  
  Storage accounts should be supplied using the diagnostics\_storage\_resource\_ids variable instead.

Type: `map(string)`

Default: `{}`

### <a name="input_diagnostics_settings_name"></a> [diagnostics\_settings\_name](#input\_diagnostics\_settings\_name)

Description: The name of the diagnostics settings. Optional, if not provided, a default name will be used.

Type: `string`

Default: `"ubiq_diagnostic_settings"`

### <a name="input_diagnostics_storage_resource_ids"></a> [diagnostics\_storage\_resource\_ids](#input\_diagnostics\_storage\_resource\_ids)

Description: Storage accounts which to add diagnostic settings and the services to log, by default all services will have diagnostics added.

Type:

```hcl
map(object({
    id            = string
    blob_enabled  = optional(bool, true)
    queue_enabled = optional(bool, true)
    table_enabled = optional(bool, true)
    file_enabled  = optional(bool, true)
  }))
```

Default: `{}`

### <a name="input_enabled_log_categories"></a> [enabled\_log\_categories](#input\_enabled\_log\_categories)

Description: List of log categories to enable in the diagnostics settings. Either enabled\_log\_categories or enabled\_log\_category\_groups can be used, but not both.  
If neither are provided, "allLogs" and "audit" category groups will be enabled by default.

Type: `list(string)`

Default: `[]`

### <a name="input_enabled_log_category_groups"></a> [enabled\_log\_category\_groups](#input\_enabled\_log\_category\_groups)

Description: List of log category groups to enable in the diagnostics settings. Either enabled\_log\_categories or enabled\_log\_category\_groups can be used, but not both.  
If neither are provided, "allLogs" and "audit" category groups will be enabled by default.

Type: `list(string)`

Default: `[]`

### <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics)

Description: List of metric categories to enable in the diagnostics settings.

Type: `list(string)`

Default: `[]`

### <a name="input_function_apps"></a> [function\_apps](#input\_function\_apps)

Description: Map of function app resource ids to configuration for function app specific alerts.

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_mssql"></a> [mssql](#input\_mssql)

Description: Configures Azure SQL and Azure SQL DB advanced auditing to send audit logs to a specified storage account.

Type:

```hcl
object({
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
```

Default: `{}`

### <a name="input_nat_gateways"></a> [nat\_gateways](#input\_nat\_gateways)

Description: Map of NAT Gateway resource ids to configuration for NAT Gateway specific alerts.

Type:

```hcl
map(object({
    resource_id         = string
    allocated_ips       = number
    snat_alert_enabled  = optional(bool, true)
    alerts_action_group = optional(string, "warning")
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description:   Key-value pairs of tags to apply to all resources in this site"

  ```terraform
  tags = {
    environment = "production"
    owner       = "team"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_traffic_manager_profiles"></a> [traffic\_manager\_profiles](#input\_traffic\_manager\_profiles)

Description: Map of Traffic Manager profile resource ids to configuration for Traffic Manager specific alerts.

Type:

```hcl
map(object({
    resource_id                     = string
    check_window                    = optional(string, "PT5M")
    endpoint_alert_action_group     = optional(string, "warning")
    all_endpoint_alert_action_group = optional(string, "critical")
  }))
```

Default: `{}`

### <a name="input_web_app"></a> [web\_app](#input\_web\_app)

Description: Configures Azure Monitor metric alerts for Azure Web Apps. Alerts will be created for each resource id provided in resource\_ids.

Type:

```hcl
object({
    resource_ids                     = optional(map(string), {})
    response_time_alert_enabled      = optional(bool, true)
    server_errors_alert_enabled      = optional(bool, true)
    health_check_alert_enabled       = optional(bool, true)
    response_time_alert_action_group = optional(string, "global")
    server_errors_alert_action_group = optional(string, "global")
    health_check_alert_action_group  = optional(string, "critical")
  })
```

Default: `{}`

## Outputs

No outputs.

## Modules

No modules.

# Additional Information

This module is created for use at Ubiq.
<!-- END_TF_DOCS -->