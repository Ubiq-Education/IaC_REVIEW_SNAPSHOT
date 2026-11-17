locals {
  container_app_identity_user_assigned = {
    for identity_id in distinct(compact(flatten([
      var.app_primary_identity.id,
      var.azure_conainter_registry.identity_resource_id,
      var.additional_identity_ids
    ]))) : identity_id => {}
  }

  # TODO: Add support for key vault reference secrets
  /**
    identity = "string"
    keyVaultUrl = "string"
    name = "string"
  **/
  container_app_secrets = concat(
    [for secret_name, secret_value in var.app_secrets : {
      name  = secret_name
      value = secret_value
    }],
    length(try(keys(var.entra_auth), [])) > 0 ? [{
      name  = "override-use-mi-fic-assertion-client-id"
      value = var.app_primary_identity.client_id
    }] : []
  )

  container_app_containers = [for container in coalesce(try(var.template.containers, null), []) : merge(
    {
      name  = container.name
      image = container.image
      resources = {
        cpu    = container.cpu
        memory = container.memory
      }
      env = distinct(concat(
        [for env in coalesce(try(container.env, null), []) : merge(
          { name = env.name },
          try(env.secret_name, null) != null ? { secretRef = env.secret_name } : {},
          try(env.value, null) != null ? { value = env.value } : {}
        )],
        [
          {
            name  = "AZURE_KEYVAULT_URL"
            value = var.cae_key_vault_uri
          },
          {
            name  = "KEY_VAULT_URI"
            value = var.cae_key_vault_uri
          },
          {
            name  = "MI_CLIENT_ID"
            value = var.app_primary_identity.client_id
          },
          {
            name  = "AZURE_CLIENT_ID"
            value = var.app_primary_identity.client_id
          },
          {
            name  = "AZURE_TENANT_ID"
            value = var.azurerm_client_config.tenant_id
          }
        ],
        var.local_app_instance_identity_client_id != null ? [{
          name  = "LOCAL_MI_CLIENT_ID"
          value = var.local_app_instance_identity_client_id
        }] : []
      ))
    },
    try(container.args, null) != null ? { args = container.args } : {},
    try(container.command, null) != null ? { command = container.command } : {},
    length(coalesce(try(container.volume_mounts, null), [])) > 0 ? {
      volumeMounts = [for volume_mount in coalesce(try(container.volume_mounts, null), []) : {
        volumeName = volume_mount.name
        mountPath  = volume_mount.path
        subPath    = try(volume_mount.sub_path, null)
      }]
    } : {},
    {
      probes = concat(
        [for probe in coalesce(try(container.liveness_probes, null), []) : merge(
          {
            type                = "Liveness"
            failureThreshold    = probe.failure_count_threshold
            initialDelaySeconds = probe.initial_delay
            periodSeconds       = probe.interval_seconds
            timeoutSeconds      = probe.timeout
          },
          try(probe.success_count_threshold, null) != null ? { successThreshold = probe.success_count_threshold } : {},
          upper(probe.transport) == "TCP" ? {
            tcpSocket = merge(
              { port = tonumber(probe.port) },
              try(probe.host, null) != null ? { host = probe.host } : {}
            )
          } : {},
          upper(probe.transport) != "TCP" ? {
            httpGet = merge(
              {
                port   = tonumber(probe.port)
                scheme = upper(probe.transport)
              },
              try(probe.host, null) != null ? { host = probe.host } : {},
              try(probe.path, null) != null ? { path = probe.path } : {},
              length(coalesce(try(probe.header, null), [])) > 0 ? {
                httpHeaders = [for header in coalesce(try(probe.header, null), []) : {
                  name  = header.name
                  value = header.value
                }]
              } : {}
            )
          } : {}
        )],
        [for probe in coalesce(try(container.readiness_probes, null), []) : merge(
          {
            type                = "Readiness"
            failureThreshold    = probe.failure_count_threshold
            initialDelaySeconds = probe.initial_delay
            periodSeconds       = probe.interval_seconds
            timeoutSeconds      = probe.timeout
          },
          try(probe.success_count_threshold, null) != null ? { successThreshold = probe.success_count_threshold } : {},
          upper(probe.transport) == "TCP" ? {
            tcpSocket = merge(
              { port = tonumber(probe.port) },
              try(probe.host, null) != null ? { host = probe.host } : {}
            )
          } : {},
          upper(probe.transport) != "TCP" ? {
            httpGet = merge(
              {
                port   = tonumber(probe.port)
                scheme = upper(probe.transport)
              },
              try(probe.host, null) != null ? { host = probe.host } : {},
              try(probe.path, null) != null ? { path = probe.path } : {},
              length(coalesce(try(probe.header, null), [])) > 0 ? {
                httpHeaders = [for header in coalesce(try(probe.header, null), []) : {
                  name  = header.name
                  value = header.value
                }]
              } : {}
            )
          } : {}
        )],
        [for probe in coalesce(try(container.startup_probes, null), []) : merge(
          {
            type                = "Startup"
            failureThreshold    = probe.failure_count_threshold
            initialDelaySeconds = probe.initial_delay
            periodSeconds       = probe.interval_seconds
            timeoutSeconds      = probe.timeout
          },
          try(probe.success_count_threshold, null) != null ? { successThreshold = probe.success_count_threshold } : {},
          upper(probe.transport) == "TCP" ? {
            tcpSocket = merge(
              { port = tonumber(probe.port) },
              try(probe.host, null) != null ? { host = probe.host } : {}
            )
          } : {},
          upper(probe.transport) != "TCP" ? {
            httpGet = merge(
              {
                port   = tonumber(probe.port)
                scheme = upper(probe.transport)
              },
              try(probe.host, null) != null ? { host = probe.host } : {},
              try(probe.path, null) != null ? { path = probe.path } : {},
              length(coalesce(try(probe.header, null), [])) > 0 ? {
                httpHeaders = [for header in coalesce(try(probe.header, null), []) : {
                  name  = header.name
                  value = header.value
                }]
              } : {}
            )
          } : {}
        )]
      )
    }
  )]

  container_app_init_containers = [for init_container in coalesce(try(var.template.init_containers, null), []) : merge(
    {
      name  = init_container.name
      image = init_container.image
      resources = {
        cpu    = init_container.cpu
        memory = init_container.memory
      }
    },
    try(init_container.args, null) != null ? { args = init_container.args } : {},
    try(init_container.command, null) != null ? { command = init_container.command } : {},
    length(coalesce(try(init_container.env, null), [])) > 0 ? {
      env = [for env in coalesce(try(init_container.env, null), []) : merge(
        { name = env.name },
        try(env.secret_name, null) != null ? { secretRef = env.secret_name } : {},
        try(env.value, null) != null ? { value = env.value } : {}
      )]
    } : {},
    length(coalesce(try(init_container.volume_mounts, null), [])) > 0 ? {
      volumeMounts = [for volume_mount in coalesce(try(init_container.volume_mounts, null), []) : {
        volumeName = volume_mount.name
        mountPath  = volume_mount.path
        subPath    = try(volume_mount.sub_path, null)
      }]
    } : {}
  )]

  container_app_volumes = [for volume in coalesce(try(var.template.volumes, null), []) : {
    name         = volume.name
    storageName  = volume.storage_name
    storageType  = volume.storage_type
    mountOptions = volume.mount_options
    secrets = [for secret in coalesce(try(volume.secrets, null), []) : {
      path      = secret.path
      secretRef = secret.secret_ref
    }]
  }]

  container_app_scale_rules = concat(
    [for rule in coalesce(try(var.template.azure_queue_scale_rules, null), []) : {
      name = rule.name
      azureQueue = merge(
        {
          queueName   = rule.queue_name
          queueLength = rule.queue_length
        },
        length(coalesce(try(rule.authentication, null), [])) > 0 ? {
          auth = [for auth in coalesce(try(rule.authentication, null), []) : {
            secretRef        = auth.secret_name
            triggerParameter = auth.trigger_parameter
          }]
        } : {}
      )
    }],
    [for rule in coalesce(try(var.template.custom_scale_rules, null), []) : {
      name = rule.name
      custom = merge(
        {
          type     = rule.custom_rule_type
          metadata = rule.metadata
        },
        length(coalesce(try(rule.authentication, null), [])) > 0 ? {
          auth = [for auth in coalesce(try(rule.authentication, null), []) : {
            secretRef        = auth.secret_name
            triggerParameter = auth.trigger_parameter
          }]
        } : {}
      )
    }],
    [for rule in coalesce(try(var.template.http_scale_rules, null), []) : {
      name = rule.name
      http = merge(
        {
          metadata = {
            concurrentRequests = tostring(rule.concurrent_requests)
          }
        },
        length(coalesce(try(rule.authentication, null), [])) > 0 ? {
          auth = [for auth in coalesce(try(rule.authentication, null), []) : {
            secretRef        = auth.secret_name
            triggerParameter = auth.trigger_parameter
          }]
        } : {}
      )
    }],
    [for rule in coalesce(try(var.template.tcp_scale_rules, null), []) : {
      name = rule.name
      tcp = merge(
        {
          metadata = {
            concurrentRequests = tostring(rule.concurrent_requests)
          }
        },
        length(coalesce(try(rule.authentication, null), [])) > 0 ? {
          auth = [for auth in coalesce(try(rule.authentication, null), []) : {
            secretRef        = auth.secret_name
            triggerParameter = auth.trigger_parameter
          }]
        } : {}
      )
    }]
  )

  container_app_ingress = var.ingress == null ? null : merge(
    {
      targetPort    = var.ingress.target_port
      allowInsecure = var.ingress.allow_insecure_connections
      external      = var.ingress.external_enabled
      transport     = var.ingress.transport
    },
    try(var.ingress.client_certificate_mode, null) != null ? {
      clientCertificateMode = var.ingress.client_certificate_mode
    } : {},
    try(var.ingress.exposed_port, null) != null ? {
      exposedPort = var.ingress.exposed_port
    } : {},
    length(coalesce(try(var.ingress.traffic_weight, null), [])) > 0 ? {
      traffic = [for weight in coalesce(try(var.ingress.traffic_weight, null), []) : merge(
        try(weight.label, null) != null ? { label = weight.label } : {},
        try(weight.latest_revision, null) != null ? { latestRevision = weight.latest_revision } : {},
        try(weight.revision_suffix, null) != null ? { revisionName = "${var.name}--${weight.revision_suffix}" } : {},
        try(weight.percentage, null) != null ? { weight = weight.percentage } : {}
      )]
    } : {},
    length(coalesce(try(var.ingress.ip_security_restriction, null), [])) > 0 ? {
      ipSecurityRestrictions = [for restriction in coalesce(try(var.ingress.ip_security_restriction, null), []) : {
        action         = restriction.action
        ipAddressRange = restriction.ip_address_range
        name           = restriction.name
        description    = restriction.description
      }]
    } : {}
  )

  container_app_body = {
    properties = {
      managedEnvironmentId = var.cae_resource_id
      workloadProfileName  = "Consumption"
      configuration = merge(
        {
          activeRevisionsMode  = "Single"
          maxInactiveRevisions = 10
          registries = [{
            server   = var.azure_conainter_registry.login_server
            identity = var.azure_conainter_registry.identity_resource_id
          }]
          secrets = local.container_app_secrets
        },
        var.dapr != null ? {
          dapr = merge(
            {},
            try(var.dapr.enabled, null) != null ? { enabled = tobool(var.dapr.enabled) } : {},
            try(var.dapr.app_id, null) != null ? { appId = var.dapr.app_id } : {},
            try(var.dapr.app_port, null) != null ? { appPort = tonumber(var.dapr.app_port) } : {},
            try(var.dapr.app_protocol, null) != null ? { appProtocol = lower(var.dapr.app_protocol) } : {},
            try(var.dapr.enable_api_logging, null) != null ? { enableApiLogging = tobool(var.dapr.enable_api_logging) } : {},
            try(var.dapr.http_max_request_size, null) != null ? { httpMaxRequestSize = tonumber(var.dapr.http_max_request_size) } : {},
            try(var.dapr.http_read_buffer_size, null) != null ? { httpReadBufferSize = tonumber(var.dapr.http_read_buffer_size) } : {},
            try(var.dapr.log_level, null) != null ? { logLevel = lower(var.dapr.log_level) } : {},
            try(var.dapr.max_concurrency, null) != null ? { maxConcurrency = tonumber(var.dapr.max_concurrency) } : {},
            try(var.dapr.app_health, null) != null ? {
              appHealth = merge(
                {},
                try(var.dapr.app_health.enabled, null) != null ? { enabled = tobool(var.dapr.app_health.enabled) } : {},
                try(var.dapr.app_health.path, null) != null ? { path = var.dapr.app_health.path } : {},
                try(var.dapr.app_health.probe_interval_seconds, null) != null ? { probeIntervalSeconds = tonumber(var.dapr.app_health.probe_interval_seconds) } : {},
                try(var.dapr.app_health.probe_timeout_milliseconds, null) != null ? { probeTimeoutMilliseconds = tonumber(var.dapr.app_health.probe_timeout_milliseconds) } : {},
                try(var.dapr.app_health.threshold, null) != null ? { threshold = tonumber(var.dapr.app_health.threshold) } : {}
              )
            } : {}
          )
        } : {},
        local.container_app_ingress != null ? { ingress = local.container_app_ingress } : {},
        var.runtime != null ? {
          runtime = merge(
            {},
            try(var.runtime.name, null) != null ? var.runtime.name == "dotnet" ? {
              dotnet = {
                autoConfigureDataProtection = try(var.runtime.dotnet_auto_configure_data_protection, false) ? var.runtime.dotnet_auto_configure_data_protection : false
              }
            } : {}
            : {},
            try(var.runtime.name, null) != null ? var.runtime.name == "java" ? {
              java = {
                enableMetrics = try(var.runtime.java_enable_metrics_exporter, false) ? var.runtime.java_enable_metrics_exporter : false
              }
            } : {}
            : {}
          )
        } : {}
      )
      template = merge(
        {
          revisionSuffix = var.template.revision_suffix
          containers     = local.container_app_containers
          scale = {
            minReplicas     = var.template.min_replicas
            maxReplicas     = var.template.max_replicas
            cooldownPeriod  = 300
            pollingInterval = 30
            rules           = local.container_app_scale_rules
          }
        },
        length(local.container_app_init_containers) > 0 ? {
          initContainers = local.container_app_init_containers
        } : {},
        length(local.container_app_volumes) > 0 ? {
          volumes = local.container_app_volumes
        } : {}
      )
    }
  }
}
