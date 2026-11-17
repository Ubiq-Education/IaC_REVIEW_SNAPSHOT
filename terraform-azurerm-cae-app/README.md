<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-cae-app

Module to deploy Ubiq standard Azure Container Apps to existing Container App Environments.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~>2.9)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~>4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~>3.7)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~>2.9)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~>4.0)

- <a name="provider_random"></a> [random](#provider\_random) (~>3.7)

## Resources

The following resources are used by this module:

- [azapi_resource.auth_config](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.managed_certificates](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_update_resource.custom_domain_binding](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [azurerm_container_app_custom_domain.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_custom_domain) (resource)
- [azurerm_role_assignment.additional_container_identity_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.kv_global_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_traffic_manager_external_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_external_endpoint) (resource)
- [random_id.traffic_manager](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_container_app_environment.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_app_environment) (data source)
- [azurerm_key_vault.cae](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_key_vault_secret.app_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) (data source)
- [azurerm_log_analytics_workspace.cae](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) (data source)
- [azurerm_user_assigned_identity.primary_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_azure_conainter_registry"></a> [azure\_conainter\_registry](#input\_azure\_conainter\_registry)

Description: The Azure Container Registry details.

Type:

```hcl
object({
    login_server         = optional(string, "cruksubiqshared.azurecr.io")
    identity_resource_id = string
  })
```

### <a name="input_cae_default_domain"></a> [cae\_default\_domain](#input\_cae\_default\_domain)

Description: The default domain of the Container App Environment.

Type: `string`

### <a name="input_cae_details"></a> [cae\_details](#input\_cae\_details)

Description: Deployment details for CAE

Type:

```hcl
object({
    key_vault_name             = string
    log_analytics_workspace_id = string
  })
```

### <a name="input_cae_location"></a> [cae\_location](#input\_cae\_location)

Description: The Azure region of the Container App Environment.

Type: `string`

### <a name="input_cae_resource_id"></a> [cae\_resource\_id](#input\_cae\_resource\_id)

Description: The resource ID of the Container App Environment where the Container App will be deployed.

Type: `string`

### <a name="input_global_resource_group_name"></a> [global\_resource\_group\_name](#input\_global\_resource\_group\_name)

Description: The name of the resource group associated with the CAE where shared non-regional resources will be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Container App. Must be unique within the Container App Environment.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group where the Container App will be deployed.

Type: `string`

### <a name="input_template"></a> [template](#input\_template)

Description:   - `max_replicas` - (Optional) The maximum number of replicas for this container.
  - `min_replicas` - (Optional) The minimum number of replicas for this container.
  - `revision_suffix` - (Optional) The suffix for the revision. This value must be unique for the lifetime of the Resource. If omitted the service will use a hash function to create one.

  ---
  `container` block supports the following:
  - `args` - (Optional) A list of extra arguments to pass to the container.
  - `command` - (Optional) A command to pass to the container to override the default. This is provided as a list of command line elements without spaces.
  - `cpu` - (Required) The amount of vCPU to allocate to the container. Possible values include `0.25`, `0.5`, `0.75`, `1.0`, `1.25`, `1.5`, `1.75`, and `2.0`. When there's a workload profile specified, there's no such constraint.
  - `image` - (Required) The image to use to create the container.
  - `memory` - (Required) The amount of memory to allocate to the container. Possible values are `0.5Gi`, `1Gi`, `1.5Gi`, `2Gi`, `2.5Gi`, `3Gi`, `3.5Gi` and `4Gi`. When there's a workload profile specified, there's no such constraint.
  - `name` - (Required) The name of the container

  ---
  `env` block supports the following:
  - `name` - (Required) The name of the environment variable for the container.
  - `secret_name` - (Optional) The name of the secret that contains the value for this environment variable.
  - `value` - (Optional) The value for this environment variable.

  ---
  `liveness_probe` block supports the following:
  - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
  - `host` - (Optional) The probe hostname. Defaults to the pod IP address. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
  - `initial_delay` - (Optional) The time in seconds to wait after the container has started before the probe is started.
  - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are in the range `1`
  - `path` - (Optional) The URI to use with the `host` for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
  - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
  - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
  - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

  ---
  `header` block supports the following:
  - `name` - (Required) The HTTP Header Name.
  - `value` - (Required) The HTTP Header value.

  ---
  `readiness_probe` block supports the following:
  - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
  - `host` - (Optional) The probe hostname. Defaults to the pod IP address. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
  - `initial_delay` - (Optional) The number of seconds elapsed after the container has started before the probe is initiated. Possible values are between `0` and `60`. Defaults to `0` seconds.
  - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are between `1` and `240`. Defaults to `10`
  - `path` - (Optional) The URI to use for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
  - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
  - `success_count_threshold` - (Optional) The number of consecutive successful responses required to consider this probe as successful. Possible values are between `1` and `10`. Defaults to `3`.
  - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
  - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

  ---
  `header` block supports the following:
  - `name` - (Required) The HTTP Header Name.
  - `value` - (Required) The HTTP Header value.

  ---
  `startup_probes` block supports the following:
  - `failure_count_threshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
  - `host` - (Optional) The value for the host header which should be sent with this probe. If unspecified, the IP Address of the Pod is used as the host header. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
  - `initial_delay` - (Optional) The number of seconds elapsed after the container has started before the probe is initiated. Possible values are between `0` and `60`. Defaults to `0` seconds.
  - `interval_seconds` - (Optional) How often, in seconds, the probe should run. Possible values are between `1` and `240`. Defaults to `10`
  - `path` - (Optional) The URI to use with the `host` for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
  - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
  - `timeout` - (Optional) Time in seconds after which the probe times out. Possible values are in the range `1`
  - `transport` - (Required) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.

  ---
  `header` block supports the following:
  - `name` - (Required) The HTTP Header Name.
  - `value` - (Required) The HTTP Header value.

  ---
  `volume_mounts` block supports the following:
  - `name` - (Required) The name of the Volume to be mounted in the container.
  - `path` - (Required) The path in the container at which to mount this volume.
  - `sub_path` - (Optional) The sub path within the volume to mount at the specified path. If not specified, the entire volume will be mounted.

  ---
  `azure_queue_scale_rule` block supports the following:
  - `name` - (Required) The name of the Scaling Rule
  - `queue_length` - (Required) The value of the length of the queue to trigger scaling actions.
  - `queue_name` - (Required) The name of the Azure Queue

  ---
  `authentication` block supports the following:
  - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
  - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

  ---
  `custom_scale_rule` block supports the following:
  - `custom_rule_type` - (Required) The Custom rule type. Possible values include: `activemq`, `artemis-queue`, `kafka`, `pulsar`, `aws-cloudwatch`, `aws-dynamodb`, `aws-dynamodb-streams`, `aws-kinesis-stream`, `aws-sqs-queue`, `azure-app-insights`, `azure-blob`, `azure-data-explorer`, `azure-eventhub`, `azure-log-analytics`, `azure-monitor`, `azure-pipelines`, `azure-servicebus`, `azure-queue`, `cassandra`, `cpu`, `cron`, `datadog`, `elasticsearch`, `external`, `external-push`, `gcp-stackdriver`, `gcp-storage`, `gcp-pubsub`, `graphite`, `http`, `huawei-cloudeye`, `ibmmq`, `influxdb`, `kubernetes-workload`, `liiklus`, `memory`, `metrics-api`, `mongodb`, `mssql`, `mysql`, `nats-jetstream`, `stan`, `tcp`, `new-relic`, `openstack-metric`, `openstack-swift`, `postgresql`, `predictkube`, `prometheus`, `rabbitmq`, `redis`, `redis-cluster`, `redis-sentinel`, `redis-streams`, `redis-cluster-streams`, `redis-sentinel-streams`, `selenium-grid`,`solace-event-queue`, and `github-runner`.
  - `metadata` - (Required)
  - `name` - (Required) The name of the Scaling Rule

  ---
  `authentication` block supports the following:
  - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
  - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

  ---
  `http_scale_rule` block supports the following:
  - `concurrent_requests` - (Required)
  - `name` - (Required) The name of the Scaling Rule

  ---
  `authentication` block supports the following:
  - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
  - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

  ---
  `init_container` block supports the following:
  - `args` - (Optional) A list of extra arguments to pass to the container.
  - `command` - (Optional) A command to pass to the container to override the default. This is provided as a list of command line elements without spaces.
  - `cpu` - (Optional) The amount of vCPU to allocate to the container. Possible values include `0.25`, `0.5`, `0.75`, `1.0`, `1.25`, `1.5`, `1.75`, and `2.0`. When there's a workload profile specified, there's no such constraint.
  - `image` - (Required) The image to use to create the container.
  - `memory` - (Optional) The amount of memory to allocate to the container. Possible values are `0.5Gi`, `1Gi`, `1.5Gi`, `2Gi`, `2.5Gi`, `3Gi`, `3.5Gi` and `4Gi`. When there's a workload profile specified, there's no such constraint.
  - `name` - (Required) The name of the container

  ---
  `env` block supports the following:
  - `name` - (Required) The name of the environment variable for the container.
  - `secret_name` - (Optional) The name of the secret that contains the value for this environment variable.
  - `value` - (Optional) The value for this environment variable.

  ---
  `volume_mounts` block supports the following:
  - `name` - (Required) The name of the Volume to be mounted in the container.
  - `path` - (Required) The path in the container at which to mount this volume.
  - `sub_path` - (Optional) The sub path within the volume to mount at the specified path. If not specified, the entire volume will be mounted.

  ---
  `tcp_scale_rule` block supports the following:
  - `concurrent_requests` - (Required)
  - `name` - (Required) The name of the Scaling Rule

  ---
  `authentication` block supports the following:
  - `secret_name` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
  - `trigger_parameter` - (Required) The Trigger Parameter name to use the supply the value retrieved from the `secret_name`.

  ---
  `volume` block supports the following:
  - `name` - (Required) The name of the volume.
  - `storage_name` - (Optional) The name of the `AzureFile` storage.
  - `storage_type` - (Optional) The type of storage volume. Possible values are `AzureFile`, `NfsAzureFile`, `EmptyDir` and `Secret`. Defaults to `EmptyDir`.
  - `mount_options` - (Optional) The mount options for the volume.
  - `secrets` - (Optional) A list of secrets to be used if the `storage_type` is `Secret`.
    - `path` - (Required) The path within the volume at which to mount this secret.
    - `secret_ref` - (Required) The name of the Container App Secret that contains the value for this secret volume.

Type:

```hcl
object({
    max_replicas    = optional(number)
    min_replicas    = optional(number)
    revision_suffix = optional(string)
    containers = list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = number
      image   = string
      memory  = string
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      liveness_probes = optional(list(object({
        failure_count_threshold = optional(number, 5)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      readiness_probes = optional(list(object({
        failure_count_threshold = optional(number, 30)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        success_count_threshold = optional(number, 3)
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      startup_probes = optional(list(object({
        failure_count_threshold = optional(number, 10)
        host                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        path                    = optional(string)
        port                    = number
        timeout                 = optional(number)
        transport               = string
        header = optional(list(object({
          name  = string
          value = string
        })))
      })))
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })))
    }))
    azure_queue_scale_rules = optional(list(object({
      name         = string
      queue_length = number
      queue_name   = string
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })))
    custom_scale_rules = optional(list(object({
      custom_rule_type = string
      metadata         = map(string)
      name             = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })))
    })))
    http_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    init_containers = optional(list(object({
      args    = optional(list(string))
      command = optional(list(string))
      cpu     = optional(number)
      image   = string
      memory  = optional(string)
      name    = string
      env = optional(list(object({
        name        = string
        secret_name = optional(string)
        value       = optional(string)
      })))
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })))
    })))
    tcp_scale_rules = optional(list(object({
      concurrent_requests = string
      name                = string
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = optional(string)
      })))
    })))
    volumes = optional(list(object({
      name          = string
      storage_name  = optional(string)
      storage_type  = optional(string)
      mount_options = optional(string)
      secrets = optional(list(object({
        path       = string
        secret_ref = string
      })))
    })))
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_add_primary_identity"></a> [add\_primary\_identity](#input\_add\_primary\_identity)

Description: The resource ID of an existing User Assigned Managed Identity to be used as the primary identity for this Container App.

Type:

```hcl
object({
    id = string
  })
```

Default: `null`

### <a name="input_additional_container_identity_roles"></a> [additional\_container\_identity\_roles](#input\_additional\_container\_identity\_roles)

Description: Additional role assignments for the Container App's User Assigned Managed Identity created for this instance by create\_app\_instance\_identity

Type:

```hcl
map(object({
    scope                = string
    role_definition_name = string
  }))
```

Default: `{}`

### <a name="input_additional_identities"></a> [additional\_identities](#input\_additional\_identities)

Description: A map of additional User Assigned Managed Identity resource IDs to be assigned to this Container App.

Type:

```hcl
map(object({
    id = string
  }))
```

Default: `{}`

### <a name="input_additional_secrets_key_vault_id"></a> [additional\_secrets\_key\_vault\_id](#input\_additional\_secrets\_key\_vault\_id)

Description: The ID of the Key Vault to use for additional secrets.

Type: `string`

Default: `null`

### <a name="input_app_secrets"></a> [app\_secrets](#input\_app\_secrets)

Description: A map of secret names to values for secrets to be created in the Container App.

Type: `map(string)`

Default: `{}`

### <a name="input_create_app_instance_identity"></a> [create\_app\_instance\_identity](#input\_create\_app\_instance\_identity)

Description: Whether to create a User Assigned Managed Identity for this Container App instance. Must be true if add\_primary\_identity is not provided.

Type: `bool`

Default: `true`

### <a name="input_custom_domains"></a> [custom\_domains](#input\_custom\_domains)

Description:   - `name` - (Required) The fully qualified name of the Custom Domain. Must be the CN or a named SAN in the certificate specified by the `container_app_environment_certificate_id`. Changing this forces a new resource to be created.
  - `certificate_binding_type` - (Optional) The type of certificate binding to use for the custom domain. Possible values are `Disabled`, `SniEnabled`, and `IpBasedEnabled`. Defaults to `Disabled`. Should be 'Disabled' if using a managed certificate.
  - `container_app_environment_certificate_id` - (Optional) The ID of the Container App Environment Certificate to use for the custom domain. Should be omitted if using a managed certificate.
  - `domain_control_validation` - (Optional) The type of domain control validation to use for the custom domain. Possible values are `TXT`, `CNAME` and `HTTP`. Defaults to `TXT`.
  ---
  `timeouts` block supports the following:
  - `create` - (Defaults to 30 minutes) Used when creating the Container App.
  - `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
  - `read` - (Defaults to 5 minutes) Used when retrieving the Container App.

Type:

```hcl
map(object({
    certificate_binding_type                 = optional(string, "Disabled")
    container_app_environment_certificate_id = optional(string)
    name                                     = string
    domain_control_validation                = optional(string, "CNAME")
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_dapr"></a> [dapr](#input\_dapr)

Description: Optional Dapr sidecar configuration for the Container App (properties.configuration.dapr).

Type:

```hcl
object({
    enabled               = optional(bool)
    app_id                = optional(string)
    app_port              = optional(number)
    app_protocol          = optional(string)
    enable_api_logging    = optional(bool)
    http_max_request_size = optional(number)
    http_read_buffer_size = optional(number)
    log_level             = optional(string)
    max_concurrency       = optional(number)
    app_health = optional(object({
      enabled                    = optional(bool)
      path                       = optional(string)
      probe_interval_seconds     = optional(number)
      probe_timeout_milliseconds = optional(number)
      threshold                  = optional(number)
    }))
  })
```

Default: `null`

### <a name="input_entra_auth_config"></a> [entra\_auth\_config](#input\_entra\_auth\_config)

Description: Configuration for Entra Container App Authentication.

Type:

```hcl
object({
    enabled                          = optional(bool, false)
    exclude_paths                    = optional(list(string))
    entra_app_registration_client_id = string
    entra_spn_client_id              = string
  })
```

Default: `null`

### <a name="input_ignore_image_version"></a> [ignore\_image\_version](#input\_ignore\_image\_version)

Description: Whether to ignore changes in the container image version to allow new container images releases outside of Terraform.

Type: `bool`

Default: `false`

### <a name="input_ingress"></a> [ingress](#input\_ingress)

Description:   - `allow_insecure_connections` - (Optional) Should this ingress allow insecure connections? Defaults to false.
  - `client_certificate_mode` - (Optional) The client certificate mode for the Ingress. Possible values are `require`, `accept`, and `ignore`.
  - `exposed_port` - (Optional) The exposed port on the container for the Ingress traffic.
  - `external_enabled` - (Optional) Are connections to this Ingress from outside the Container App Environment enabled? Defaults to `false`.
  - `target_port` - (Required) The target port on the container for the Ingress traffic.
  - `transport` - (Optional) The transport method for the Ingress. Possible values are `Auto`, `Http`, `Http2` and `Tcp`. Defaults to `Auto`.

  ---
  `ip_security_restriction` block supports the following:
  - `action` - (Required) The IP-filter action. `Allow` or `Deny`.
  - `description` - (Optional) Describe the IP restriction rule that is being sent to the container-app.
  - `ip_address_range` - (Required) The incoming IP address or range of IP addresses (in CIDR notation).
  - `name` - (Required) Name for the IP restriction rule.

  ---
  `traffic_weight` block supports the following:
  - `label` - (Optional) The label to apply to the revision as a name prefix for routing traffic.
  - `latest_revision` - (Optional) This traffic Weight applies to the latest stable Container Revision. At most only one `traffic_weight` block can have the `latest_revision` set to `true`.
  - `percentage` - (Required) The percentage of traffic which should be sent this revision.
  - `revision_suffix` - (Optional) The suffix string to which this `traffic_weight` applies.

Type:

```hcl
object({
    allow_insecure_connections = optional(bool)
    client_certificate_mode    = optional(string)
    exposed_port               = optional(number)
    external_enabled           = optional(bool)
    target_port                = number
    transport                  = optional(string)
    ip_security_restriction = optional(list(object({
      action           = string
      description      = optional(string)
      ip_address_range = string
      name             = string
    })))
    traffic_weight = list(object({
      label           = optional(string)
      latest_revision = optional(bool)
      percentage      = number
      revision_suffix = optional(string)
    }))
  })
```

Default: `null`

### <a name="input_key_vault_secret_ids"></a> [key\_vault\_secret\_ids](#input\_key\_vault\_secret\_ids)

Description: A map of key vault secret versionless IDs to be used in the container app.

Type: `map(string)`

Default: `{}`

### <a name="input_readiness_probe_failure_alert_enabled"></a> [readiness\_probe\_failure\_alert\_enabled](#input\_readiness\_probe\_failure\_alert\_enabled)

Description: Whether to enable the readiness failure alert to monitor container readiness probes. This should only be enabled once per log analytics workspace.

Type: `bool`

Default: `false`

### <a name="input_replica_count_alert_enabled"></a> [replica\_count\_alert\_enabled](#input\_replica\_count\_alert\_enabled)

Description: Whether to enable the replica count alert for this Container App. This alert is triggered when the number of replicas reaches the `replica_count_threshold` specified in the `monitoring_diagnostics` module.

Type: `bool`

Default: `true`

### <a name="input_runtime"></a> [runtime](#input\_runtime)

Description: Optional runtime configuration for the Container App (properties.configuration.runtime).

Type:

```hcl
object({
    name                                  = string
    dotnet_auto_configure_data_protection = optional(bool)
    java_enable_metrics_exporter          = optional(bool)
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags to be applied to the resources

Type: `map(string)`

Default: `{}`

### <a name="input_traffic_manager_endpoint"></a> [traffic\_manager\_endpoint](#input\_traffic\_manager\_endpoint)

Description:   This block defines the configuration for the Traffic Manager endpoint associated with the Container App.
  - `add_endpoint` - (Optional) Should a Traffic Manager endpoint be created? Defaults to `true`.
  - `name` - (Optional) The name of the Traffic Manager endpoint. If not specified, a random name will be generated.
  - `profile_id` - (Required) The ID of the Traffic Manager profile to which this endpoint belongs.
  - `enabled` - (Optional) Is this Traffic Manager endpoint enabled? Defaults to `true`.
  - `always_serve_enabled` - (Optional) Should this endpoint always serve traffic? Defaults to `false`.
  - `weight` - (Optional) The weight of this endpoint for load balancing. Defaults to `100`.
  - `endpoint_location` - (Optional) The location of the Traffic Manager endpoint. If not specified, it will default to the Container App Environment's location.
  - `target` - (Optional) The target of the Traffic Manager endpoint. If not specified, it will default to the Container App's default domain.

Type:

```hcl
object({
    add_endpoint         = optional(bool, true)
    name                 = optional(string)
    profile_id           = string
    enabled              = optional(bool, true)
    always_serve_enabled = optional(bool, false)
    weight               = optional(number, 100)
    endpoint_location    = optional(string)
    target               = optional(string)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_container_app"></a> [container\_app](#output\_container\_app)

Description: The Container App resource.

## Modules

The following Modules are called:

### <a name="module_avm-res-managedidentity-userassignedidentity-app"></a> [avm-res-managedidentity-userassignedidentity-app](#module\_avm-res-managedidentity-userassignedidentity-app)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~>0.3

### <a name="module_container_app"></a> [container\_app](#module\_container\_app)

Source: ./modules/container_app

Version:

### <a name="module_monitoring_diagnostics"></a> [monitoring\_diagnostics](#module\_monitoring\_diagnostics)

Source: api.controlmonkey.io/o-26drsisx9g/monitoring-diagnostics/azurerm

Version: ~>1.2

### <a name="module_short-region-lookup"></a> [short-region-lookup](#module\_short-region-lookup)

Source: api.controlmonkey.io/o-26drsisx9g/short-region-lookup/azurerm

Version: ~>1.0.0

# Additional Information

This module is created for use at Ubiq.
<!-- END_TF_DOCS -->