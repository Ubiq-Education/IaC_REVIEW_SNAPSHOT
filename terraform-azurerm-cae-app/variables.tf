variable "name" {
  type        = string
  description = "The name of the Container App. Must be unique within the Container App Environment."
}

variable "cae_resource_id" {
  type        = string
  description = "The resource ID of the Container App Environment where the Container App will be deployed."
}

variable "cae_location" {
  type        = string
  description = "The Azure region of the Container App Environment."
}

variable "cae_default_domain" {
  type        = string
  description = "The default domain of the Container App Environment."
}

variable "cae_details" {
  type = object({
    key_vault_name             = string
    log_analytics_workspace_id = string
  })
  description = "Deployment details for CAE"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Container App will be deployed."
}

variable "global_resource_group_name" {
  type        = string
  description = "The name of the resource group associated with the CAE where shared non-regional resources will be deployed."
}

variable "additional_secrets_key_vault_id" {
  type        = string
  description = "The ID of the Key Vault to use for additional secrets."
  default     = null

  validation {
    error_message = "additional_secrets_key_vault_id must be provided if key_vault_secret_ids is used."
    condition     = length(var.key_vault_secret_ids) > 0 ? var.additional_secrets_key_vault_id != null : true
  }
}

variable "key_vault_secret_ids" {
  type        = map(string)
  description = "A map of key vault secret versionless IDs to be used in the container app."
  default     = {}
}

variable "app_secrets" {
  type        = map(string)
  description = "A map of secret names to values for secrets to be created in the Container App."
  default     = {}
}

variable "azure_conainter_registry" {
  type = object({
    login_server         = optional(string, "cruksubiqshared.azurecr.io")
    identity_resource_id = string
  })
  description = "The Azure Container Registry details."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to the resources"
}

variable "template" {
  type = object({
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
  description = <<DESCRIPTION
  - `max_replicas` - (Optional) The maximum number of replicas for this container.
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
  DESCRIPTION
  nullable    = false

  validation {
    error_message = "volume.storage_type must be one of `AzureFile`, `EmptyDir`, `NfsAzureFile`, `Secret`"
    condition = alltrue([
      for volume in coalesce(var.template.volumes, []) : contains([
        "AzureFile",
        "EmptyDir",
        "NfsAzureFile",
        "Secret"
      ], coalesce(volume.storage_type, "EmptyDir"))
    ])
  }
}

variable "custom_domains" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  - `name` - (Required) The fully qualified name of the Custom Domain. Must be the CN or a named SAN in the certificate specified by the `container_app_environment_certificate_id`. Changing this forces a new resource to be created.
  - `certificate_binding_type` - (Optional) The type of certificate binding to use for the custom domain. Possible values are `Disabled`, `SniEnabled`, and `IpBasedEnabled`. Defaults to `Disabled`. Should be 'Disabled' if using a managed certificate.
  - `container_app_environment_certificate_id` - (Optional) The ID of the Container App Environment Certificate to use for the custom domain. Should be omitted if using a managed certificate.
  - `domain_control_validation` - (Optional) The type of domain control validation to use for the custom domain. Possible values are `TXT`, `CNAME` and `HTTP`. Defaults to `TXT`.
  ---
  `timeouts` block supports the following:
  - `create` - (Defaults to 30 minutes) Used when creating the Container App.
  - `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
  - `read` - (Defaults to 5 minutes) Used when retrieving the Container App.
  DESCRIPTION
  nullable    = false

  validation {
    error_message = "Only amais.com custom domains and sub domains are currently supported. Name must end with '.amais.com' or 'wkflo.ai'."
    condition = alltrue([
      for domain in values(var.custom_domains) : endswith(domain.name, ".amais.com") || endswith(domain.name, ".wkflo.ai")
    ])
  }
}

variable "ingress" {
  type = object({
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
  default     = null
  description = <<DESCRIPTION
  - `allow_insecure_connections` - (Optional) Should this ingress allow insecure connections? Defaults to false.
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
  DESCRIPTION
}

variable "dapr" {
  type = object({
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
  default     = null
  description = "Optional Dapr sidecar configuration for the Container App (properties.configuration.dapr)."

  validation {
    error_message = "dapr.app_protocol must be one of `http`, `grpc` when provided."
    condition     = var.dapr == null || try(var.dapr.app_protocol, null) == null ? true : contains(["http", "grpc"], var.dapr.app_protocol)
  }

  validation {
    error_message = "dapr.log_level must be one of `debug`, `info`, `warn`, `error` when provided."
    condition     = var.dapr == null || try(var.dapr.log_level, null) == null ? true : contains(["debug", "info", "warn", "error"], var.dapr.log_level)
  }
}

variable "runtime" {
  type = object({
    name                                  = string
    dotnet_auto_configure_data_protection = optional(bool)
    java_enable_metrics_exporter          = optional(bool)
  })
  default     = null
  description = "Optional runtime configuration for the Container App (properties.configuration.runtime)."

  validation {
    error_message = "Supported values for name are `dotnet` and `java`."
    condition     = var.runtime == null ? true : contains(["dotnet", "java"], var.runtime.name)
  }

  validation {
    error_message = "dotnet_auto_configure_data_protection can only be used when runtime.name is `dotnet`."
    condition     = var.runtime == null || var.runtime.name != "dotnet" ? true : try(var.runtime.dotnet_auto_configure_data_protection, null) != null
  }

  validation {
    error_message = "java_enable_metrics_exporter can only be used when runtime.name is `java`."
    condition     = var.runtime == null || var.runtime.name != "java" ? true : try(var.runtime.java_enable_metrics_exporter, null) != null
  }
}

variable "traffic_manager_endpoint" {
  type = object({
    add_endpoint         = optional(bool, true)
    name                 = optional(string)
    profile_id           = string
    enabled              = optional(bool, true)
    always_serve_enabled = optional(bool, false)
    weight               = optional(number, 100)
    endpoint_location    = optional(string)
    target               = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
  This block defines the configuration for the Traffic Manager endpoint associated with the Container App.
  - `add_endpoint` - (Optional) Should a Traffic Manager endpoint be created? Defaults to `true`.
  - `name` - (Optional) The name of the Traffic Manager endpoint. If not specified, a random name will be generated.
  - `profile_id` - (Required) The ID of the Traffic Manager profile to which this endpoint belongs.
  - `enabled` - (Optional) Is this Traffic Manager endpoint enabled? Defaults to `true`.
  - `always_serve_enabled` - (Optional) Should this endpoint always serve traffic? Defaults to `false`.
  - `weight` - (Optional) The weight of this endpoint for load balancing. Defaults to `100`.
  - `endpoint_location` - (Optional) The location of the Traffic Manager endpoint. If not specified, it will default to the Container App Environment's location.
  - `target` - (Optional) The target of the Traffic Manager endpoint. If not specified, it will default to the Container App's default domain.
  DESCRIPTION

  validation {
    error_message = "traffic_manager_endpoint.profile_id must be provided if traffic_manager_endpoint is variable is used."
    condition     = var.traffic_manager_endpoint != null ? var.traffic_manager_endpoint.profile_id != null : true
  }
}

variable "entra_auth_config" {
  type = object({
    enabled                          = optional(bool, false)
    exclude_paths                    = optional(list(string))
    entra_app_registration_client_id = string
    entra_spn_client_id              = string
  })
  default     = null
  description = "Configuration for Entra Container App Authentication."
}

variable "add_primary_identity" {
  type = object({
    id = string
  })
  default     = null
  description = "The resource ID of an existing User Assigned Managed Identity to be used as the primary identity for this Container App."
}

variable "additional_identities" {
  type = map(object({
    id = string
  }))
  default     = {}
  description = "A map of additional User Assigned Managed Identity resource IDs to be assigned to this Container App."
}

variable "create_app_instance_identity" {
  type        = bool
  default     = true
  description = "Whether to create a User Assigned Managed Identity for this Container App instance. Must be true if add_primary_identity is not provided."

  validation {
    error_message = "create_app_instance_identity must be true if add_primary_identity is not provided."
    condition     = var.add_primary_identity == null ? var.create_app_instance_identity == true : true
  }
}

variable "additional_container_identity_roles" {
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default     = {}
  description = "Additional role assignments for the Container App's User Assigned Managed Identity created for this instance by create_app_instance_identity"

  validation {
    error_message = "additional_container_identity_roles can only be used if create_app_instance_identity is true."
    condition     = var.create_app_instance_identity ? true : length(var.additional_container_identity_roles) == 0
  }
}

variable "ignore_image_version" {
  type        = bool
  default     = false
  description = "Whether to ignore changes in the container image version to allow new container images releases outside of Terraform."
}

variable "replica_count_alert_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable the replica count alert for this Container App. This alert is triggered when the number of replicas reaches the `replica_count_threshold` specified in the `monitoring_diagnostics` module."
}

variable "readiness_probe_failure_alert_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the readiness failure alert to monitor container readiness probes. This should only be enabled once per log analytics workspace."
}
