<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-dxp-appservice

Module to create the infrastructure required to deploy a DXP app service.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~>1.9)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~>2.0)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (~>3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~>4.9)

- <a name="requirement_time"></a> [time](#requirement\_time) (~>0.12)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~>2.0)

- <a name="provider_azuread"></a> [azuread](#provider\_azuread) (~>3.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~>4.9)

- <a name="provider_azurerm.shared"></a> [azurerm.shared](#provider\_azurerm.shared) (~>4.9)

- <a name="provider_time"></a> [time](#provider\_time) (~>0.12)

## Resources

The following resources are used by this module:

- [azapi_update_resource.main_webapp_additional_slot_properties](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_properties](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azapi_update_resource.main_webapp_staging_properties](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azuread_app_role_assignment.dxp_client_prod](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) (resource)
- [azuread_app_role_assignment.dxp_client_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) (resource)
- [azuread_group_member.app_cosmos_db_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.app_cosmos_db_access_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.app_dxp_umi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.app_dxp_umi_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.app_sql_db_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azuread_group_member.app_sql_db_access_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) (resource)
- [azurerm_managed_redis_access_policy_assignment.app_redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment) (resource)
- [azurerm_managed_redis_access_policy_assignment.app_staging_redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_redis_access_policy_assignment) (resource)
- [azurerm_monitor_diagnostic_setting.main_webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_monitor_diagnostic_setting.main_webapp_additional_slot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_monitor_diagnostic_setting.main_webapp_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_role_assignment.app_additional_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.app_additional_roles_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.main_kv_app_secret_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.main_kv_app_secret_user_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.shared_kv_app_secret_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.shared_kv_app_secret_user_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_windows_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) (resource)
- [azurerm_windows_web_app_slot.main_additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app_slot) (resource)
- [azurerm_windows_web_app_slot.main_staging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app_slot) (resource)
- [time_sleep.azurerm_managedidentity_all](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.azurerm_roles_all](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azuread_application.dxp_api_prod](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_application.dxp_api_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) (data source)
- [azuread_group.dxp_app_umi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.dxp_app_umi_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.dxp_cosmos_db_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.dxp_sql_db_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_group.dxp_sql_db_access_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_service_principal.dxp_api_prod](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) (data source)
- [azuread_service_principal.dxp_api_staging](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) (data source)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_key_vault.shared](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_key_vault_secret.amais_dxp_superadmin_secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_log_analytics_workspace.shared](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) (data source)
- [azurerm_managed_redis.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_redis) (data source)
- [azurerm_mssql_server.dxp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_server) (data source)
- [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
- [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/service_plan) (data source)
- [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) (data source)
- [azurerm_subnet.hub_centralindia_tg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subnet.hub_uksouth_devops_01](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subnet.hub_uksouth_devops_02](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subnet.hub_uksouth_tg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subnet.vnet_integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_webapp_name"></a> [webapp\_name](#input\_webapp\_name)

Description: The base name to use for the web app.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_add_global_cosmos_db_connection_info"></a> [add\_global\_cosmos\_db\_connection\_info](#input\_add\_global\_cosmos\_db\_connection\_info)

Description: Add the global DXP cosmos db connection info to the app settings.

Type: `bool`

Default: `false`

### <a name="input_analytics_db_connection_enabled_production"></a> [analytics\_db\_connection\_enabled\_production](#input\_analytics\_db\_connection\_enabled\_production)

Description: Enable the analytics database connection string for the production slot.

Type: `bool`

Default: `false`

### <a name="input_analytics_db_connection_enabled_staging"></a> [analytics\_db\_connection\_enabled\_staging](#input\_analytics\_db\_connection\_enabled\_staging)

Description: Enable the analytics database connection string for the staging slot.

Type: `bool`

Default: `false`

### <a name="input_analytics_db_connection_sql_db_name_max_pool_size"></a> [analytics\_db\_connection\_sql\_db\_name\_max\_pool\_size](#input\_analytics\_db\_connection\_sql\_db\_name\_max\_pool\_size)

Description: The max pool size for the analytics SQL database connection string.

Type: `number`

Default: `900`

### <a name="input_analytics_db_connection_sql_db_name_max_pool_size_staging"></a> [analytics\_db\_connection\_sql\_db\_name\_max\_pool\_size\_staging](#input\_analytics\_db\_connection\_sql\_db\_name\_max\_pool\_size\_staging)

Description: The max pool size for the staging analytics SQL database connection string.

Type: `number`

Default: `200`

### <a name="input_analytics_service_connection_enabled_production"></a> [analytics\_service\_connection\_enabled\_production](#input\_analytics\_service\_connection\_enabled\_production)

Description: Add the analytics service connection environment variables for the web app production slot.

Type: `bool`

Default: `false`

### <a name="input_analytics_service_connection_enabled_staging"></a> [analytics\_service\_connection\_enabled\_staging](#input\_analytics\_service\_connection\_enabled\_staging)

Description: Add the analytics service connection environment variables for the web app staging slot.

Type: `bool`

Default: `false`

### <a name="input_app_autoscale_name_override"></a> [app\_autoscale\_name\_override](#input\_app\_autoscale\_name\_override)

Description: Manually specifiy the name of the autoscale setting. If not set, a name will be generated.

Type: `string`

Default: `null`

### <a name="input_app_autoscale_rule_profiles"></a> [app\_autoscale\_rule\_profiles](#input\_app\_autoscale\_rule\_profiles)

Description: Autoscale rule profiles to apply to the app service plan.

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_app_autoscale_rule_profiles_enabled"></a> [app\_autoscale\_rule\_profiles\_enabled](#input\_app\_autoscale\_rule\_profiles\_enabled)

Description: Enable/disable the autoscale rule profiles.

Type: `bool`

Default: `true`

### <a name="input_app_autoscale_rule_profiles_notification"></a> [app\_autoscale\_rule\_profiles\_notification](#input\_app\_autoscale\_rule\_profiles\_notification)

Description:   (Optional) A notification block associated to autoscale setting. Defaults to null.
  - `email` - (Optional) A email block as defined below.
    - `send_to_subscription_administrator` - (Optional) Should email notifications be sent to the subscription administrator? Defaults to false.
    - `send_to_subscription_co_administrator` - (Optional) Should email notifications be sent to the subscription co-administrator? Defaults to false.
    - `custom_emails` - (Optional) Specifies a list of custom email addresses to which the email notifications will be sent.
  - `webhook` - (Optional) One or more webhook blocks as defined below.
    - `service_uri` - (Required) The HTTPS URI which should receive scale notifications.
    - `properties` - (Optional) A map of settings.

Type:

```hcl
object({
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
```

Default: `null`

### <a name="input_app_identity_roles_production"></a> [app\_identity\_roles\_production](#input\_app\_identity\_roles\_production)

Description: List of additional roles to assign to the app production identity

Type:

```hcl
map(object({
    scope                = string
    role_definition_name = string
  }))
```

Default: `{}`

### <a name="input_app_identity_roles_staging"></a> [app\_identity\_roles\_staging](#input\_app\_identity\_roles\_staging)

Description: List of additional roles to assign to the app staging identity

Type:

```hcl
map(object({
    scope                = string
    role_definition_name = string
  }))
```

Default: `{}`

### <a name="input_app_instance_count"></a> [app\_instance\_count](#input\_app\_instance\_count)

Description: The number of instances to run for this site. Ignored if using autoscale rules.

Type: `number`

Default: `1`

### <a name="input_app_slots"></a> [app\_slots](#input\_app\_slots)

Description:   A map of slots and additional app settinngs for the web app.  
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

Type:

```hcl
map(object({
    app_settings_base_slot   = optional(string)
    app_settings             = map(string)
    app_stack_dotnet_version = optional(string, "v10.0")
  }))
```

Default: `{}`

### <a name="input_app_stack_dotnet_version_production"></a> [app\_stack\_dotnet\_version\_production](#input\_app\_stack\_dotnet\_version\_production)

Description: The version of the .NET stack to use for this site.

Type: `string`

Default: `"v8.0"`

### <a name="input_app_stack_dotnet_version_staging"></a> [app\_stack\_dotnet\_version\_staging](#input\_app\_stack\_dotnet\_version\_staging)

Description: The version of the .NET stack to use for this site.

Type: `string`

Default: `"v8.0"`

### <a name="input_auth0_oauth_settings_enabled_production"></a> [auth0\_oauth\_settings\_enabled\_production](#input\_auth0\_oauth\_settings\_enabled\_production)

Description: Enable Auth0 OAuth settings on the production slot.

Type: `bool`

Default: `false`

### <a name="input_auth0_oauth_settings_enabled_staging"></a> [auth0\_oauth\_settings\_enabled\_staging](#input\_auth0\_oauth\_settings\_enabled\_staging)

Description: Enable Auth0 OAuth settings on the staging slot.

Type: `bool`

Default: `false`

### <a name="input_az_long_region"></a> [az\_long\_region](#input\_az\_long\_region)

Description: Azure region name, e.g eastus, southcentralus, uksouth, etc.

Type: `string`

Default: `"uksouth"`

### <a name="input_client_affinity_enabled"></a> [client\_affinity\_enabled](#input\_client\_affinity\_enabled)

Description: Enable client affinity for the web app.

Type: `bool`

Default: `false`

### <a name="input_db_connection_sql_db_name"></a> [db\_connection\_sql\_db\_name](#input\_db\_connection\_sql\_db\_name)

Description: The name of the Azure SQL database to connect to.

Type: `string`

Default: `"AMAIS-DXP-MD"`

### <a name="input_db_connection_sql_db_name_max_pool_size"></a> [db\_connection\_sql\_db\_name\_max\_pool\_size](#input\_db\_connection\_sql\_db\_name\_max\_pool\_size)

Description: The max pool size for the SQL database connection string.

Type: `number`

Default: `1200`

### <a name="input_db_connection_sql_db_name_max_pool_size_staging"></a> [db\_connection\_sql\_db\_name\_max\_pool\_size\_staging](#input\_db\_connection\_sql\_db\_name\_max\_pool\_size\_staging)

Description: The max pool size for the staging SQL database connection string.

Type: `number`

Default: `200`

### <a name="input_db_connection_sql_db_name_staging_override"></a> [db\_connection\_sql\_db\_name\_staging\_override](#input\_db\_connection\_sql\_db\_name\_staging\_override)

Description:   The name of the Azure SQL database to connect to on the staging slot.  
  If not set, '-STAGING' will be appended to the db\_connection\_sql\_db\_name.

Type: `string`

Default: `null`

### <a name="input_db_connection_sql_server_fqdn"></a> [db\_connection\_sql\_server\_fqdn](#input\_db\_connection\_sql\_server\_fqdn)

Description:   The fqdn of the Azure SQL Server to connect to  
  Expects logging databases with names: AMAIS-DXP-LOGGING and AMAIS-DXP-STAGING-LOGGING.

Type: `string`

Default: `"amais-dxp.database.windows.net"`

### <a name="input_db_connection_use_entra_auth_production"></a> [db\_connection\_use\_entra\_auth\_production](#input\_db\_connection\_use\_entra\_auth\_production)

Description:   Use Entra authentication for the SQL connection on the production slot. If false, use the default credentials retrieved from the key vault.

Type: `bool`

Default: `true`

### <a name="input_db_connection_use_entra_auth_staging"></a> [db\_connection\_use\_entra\_auth\_staging](#input\_db\_connection\_use\_entra\_auth\_staging)

Description:   Use Entra authentication for the SQL connection on the staging slot. If false, use the default credentials retrieved from the key vault.

Type: `bool`

Default: `true`

### <a name="input_distilled_connection_enabled_production"></a> [distilled\_connection\_enabled\_production](#input\_distilled\_connection\_enabled\_production)

Description: Enable the distilled connection string for the production slot.

Type: `bool`

Default: `false`

### <a name="input_distilled_connection_enabled_staging"></a> [distilled\_connection\_enabled\_staging](#input\_distilled\_connection\_enabled\_staging)

Description: Enable the distilled connection string for the staging slot.

Type: `bool`

Default: `false`

### <a name="input_distilled_location"></a> [distilled\_location](#input\_distilled\_location)

Description: The location for the distilled service (DistilledSettings\_\_Location).

Type: `string`

Default: `"s3://queries.external.337909766656.us-east-1"`

### <a name="input_distilled_workgroup"></a> [distilled\_workgroup](#input\_distilled\_workgroup)

Description: The workgroup for the distilled service (DistilledSettings\_\_WorkGroup).

Type: `string`

Default: `"DistilledResolutions"`

### <a name="input_do_not_format_app_name"></a> [do\_not\_format\_app\_name](#input\_do\_not\_format\_app\_name)

Description: Do not format the app name.

Type: `bool`

Default: `false`

### <a name="input_dxp_ingress_eventhub_namespace_name"></a> [dxp\_ingress\_eventhub\_namespace\_name](#input\_dxp\_ingress\_eventhub\_namespace\_name)

Description: The name of the dxp-ingress event hub namespace where any eventhub instances can be found.

Type: `string`

Default: `"amais-dxp-ingress"`

### <a name="input_dxp_redis_cache_enabled"></a> [dxp\_redis\_cache\_enabled](#input\_dxp\_redis\_cache\_enabled)

Description: Add the DXP Redis cache environment variables for the web app.

Type: `bool`

Default: `false`

### <a name="input_dxp_vnet_alias"></a> [dxp\_vnet\_alias](#input\_dxp\_vnet\_alias)

Description: The alias for the DXP virtual network

Type: `string`

Default: `"dxp-01"`

### <a name="input_elastic_search_settings_enabled"></a> [elastic\_search\_settings\_enabled](#input\_elastic\_search\_settings\_enabled)

Description: Enable Elastic Search settings.

Type: `bool`

Default: `false`

### <a name="input_elastic_search_tenant_data_stream_slot"></a> [elastic\_search\_tenant\_data\_stream\_slot](#input\_elastic\_search\_tenant\_data\_stream\_slot)

Description: The slot to use for the tenant data stream.

Type: `string`

Default: `"production"`

### <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled)

Description: Enable the health check endpoint for the web app.

Type: `bool`

Default: `true`

### <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min)

Description: The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10.

Type: `number`

Default: `10`

### <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path)

Description: The path to the health check endpoint for the web app. Default if not set is /api/v1/healthcheck

Type: `string`

Default: `"/api/v1/healthcheck"`

### <a name="input_ingress_service_connection_enabled_production"></a> [ingress\_service\_connection\_enabled\_production](#input\_ingress\_service\_connection\_enabled\_production)

Description: Add the ingress service connection environment variables for the web app production slot.

Type: `bool`

Default: `false`

### <a name="input_ingress_service_connection_enabled_staging"></a> [ingress\_service\_connection\_enabled\_staging](#input\_ingress\_service\_connection\_enabled\_staging)

Description: Add the ingress service connection environment variables for the web app staging slot.

Type: `bool`

Default: `false`

### <a name="input_mapped_storage_accounts"></a> [mapped\_storage\_accounts](#input\_mapped\_storage\_accounts)

Description: List of storage account configurations

Type:

```hcl
list(object({
    type                   = string
    name                   = string
    account_name           = string
    storage_resource_group = string
    share_name             = string
    mount_path             = string
  }))
```

Default: `null`

### <a name="input_mi_dxp_api_roles_production"></a> [mi\_dxp\_api\_roles\_production](#input\_mi\_dxp\_api\_roles\_production)

Description: Entra roles to assign to the web app managed identity. The roles will be assigned on the API envionment matching the production slot.

Type: `list(string)`

Default: `[]`

### <a name="input_mi_dxp_api_roles_staging"></a> [mi\_dxp\_api\_roles\_staging](#input\_mi\_dxp\_api\_roles\_staging)

Description: Entra roles to assign to the web app managed identity. The roles will be assigned on the API envionment matching the staging slot

Type: `list(string)`

Default: `[]`

### <a name="input_notification_service_connection_enabled_production"></a> [notification\_service\_connection\_enabled\_production](#input\_notification\_service\_connection\_enabled\_production)

Description: Add the notification service connection environment variables for the web app production slot.

Type: `bool`

Default: `false`

### <a name="input_notification_service_connection_enabled_staging"></a> [notification\_service\_connection\_enabled\_staging](#input\_notification\_service\_connection\_enabled\_staging)

Description: Add the notification service connection environment variables for the web app staging slot.

Type: `bool`

Default: `false`

### <a name="input_redis_cache_enabled"></a> [redis\_cache\_enabled](#input\_redis\_cache\_enabled)

Description: Whether to add the DXP Redis cache environment variables for the web app and add access for the managed identity to the Redis cache instance.

Type: `bool`

Default: `true`

### <a name="input_report_service_connection_enabled_production"></a> [report\_service\_connection\_enabled\_production](#input\_report\_service\_connection\_enabled\_production)

Description: Add the report service connection environment variables for the web app production slot.

Type: `bool`

Default: `false`

### <a name="input_report_service_connection_enabled_staging"></a> [report\_service\_connection\_enabled\_staging](#input\_report\_service\_connection\_enabled\_staging)

Description: Add the report service connection environment variables for the web app staging slot.

Type: `bool`

Default: `false`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to deploy this site.

Type: `string`

Default: `"Amais-DXP"`

### <a name="input_service_plan_name_override"></a> [service\_plan\_name\_override](#input\_service\_plan\_name\_override)

Description: Optional: The name of the service plan to use for this site.

Type: `string`

Default: `null`

### <a name="input_service_plan_sku"></a> [service\_plan\_sku](#input\_service\_plan\_sku)

Description: The SKU of the service plan to use for this site.

Type: `string`

Default: `"P0v3"`

### <a name="input_sub_id"></a> [sub\_id](#input\_sub\_id)

Description: The guid id of the subscription in which to deploy this site.

Type: `string`

Default: `"c94f8a3d-8d0b-4660-85de-26004f233dbf"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A map of tags to apply to all resources.

Type: `map(string)`

Default: `{}`

### <a name="input_use_existing_service_plan"></a> [use\_existing\_service\_plan](#input\_use\_existing\_service\_plan)

Description: Use an existing app service plan for this site.

Type: `bool`

Default: `false`

### <a name="input_waf_azure_fdid_lockdown"></a> [waf\_azure\_fdid\_lockdown](#input\_waf\_azure\_fdid\_lockdown)

Description: value for the X-Azure-FDID header to restrict the web app slots to only be accessible via the WAF. Plus which slots to apply ip restrictions to.

Type:

```hcl
object({
    x_azure_fdid_value = string
    production         = optional(bool, true)
    staging            = optional(bool, true)
    others             = optional(bool, true)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_production_identity_principal_id"></a> [production\_identity\_principal\_id](#output\_production\_identity\_principal\_id)

Description: n/a

### <a name="output_production_identity_resource_id"></a> [production\_identity\_resource\_id](#output\_production\_identity\_resource\_id)

Description: n/a

### <a name="output_staging_identity_principal_id"></a> [staging\_identity\_principal\_id](#output\_staging\_identity\_principal\_id)

Description: n/a

### <a name="output_staging_identity_resource_id"></a> [staging\_identity\_resource\_id](#output\_staging\_identity\_resource\_id)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_avm-res-insights-autoscalesetting"></a> [avm-res-insights-autoscalesetting](#module\_avm-res-insights-autoscalesetting)

Source: Azure/avm-res-insights-autoscalesetting/azurerm

Version: ~>0.1

### <a name="module_avm-res-managedidentity-userassignedidentity-app"></a> [avm-res-managedidentity-userassignedidentity-app](#module\_avm-res-managedidentity-userassignedidentity-app)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_avm-res-managedidentity-userassignedidentity-app-staging"></a> [avm-res-managedidentity-userassignedidentity-app-staging](#module\_avm-res-managedidentity-userassignedidentity-app-staging)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_short-region-lookup"></a> [short-region-lookup](#module\_short-region-lookup)

Source: api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm

Version: ~>1.0.0

# Additional Information

This module is created for use at Ubiq.
<!-- END_TF_DOCS -->