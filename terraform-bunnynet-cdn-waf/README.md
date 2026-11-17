<!-- BEGIN_TF_DOCS -->
# terraform-bunnynet-cdn-waf

Module to create a standardised Bunny.net CDN and WAF configuration

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~>1.9)

- <a name="requirement_bunnynet"></a> [bunnynet](#requirement\_bunnynet) (>=0.19.2, <0.21.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (~>0.12)

## Providers

The following providers are used by this module:

- <a name="provider_bunnynet"></a> [bunnynet](#provider\_bunnynet) (>=0.19.2, <0.21.0)

- <a name="provider_time"></a> [time](#provider\_time) (~>0.12)

## Resources

The following resources are used by this module:

- [bunnynet_pullzone.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone) (resource)
- [bunnynet_pullzone_access_list.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_access_list) (resource)
- [bunnynet_pullzone_edgerule.add_x_headers](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_edgerule) (resource)
- [bunnynet_pullzone_edgerule.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_edgerule) (resource)
- [bunnynet_pullzone_hostname.custom](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_hostname) (resource)
- [bunnynet_pullzone_hostname.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_hostname) (resource)
- [bunnynet_pullzone_ratelimit_rule.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_ratelimit_rule) (resource)
- [bunnynet_pullzone_shield.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_shield) (resource)
- [bunnynet_pullzone_waf_rule.main](https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_waf_rule) (resource)
- [time_sleep.bunnynet_pullzone_shield](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_pullzone_config"></a> [pullzone\_config](#input\_pullzone\_config)

Description:   Configuration for the pull zone.  
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone

Type:

```hcl
object({
    name                  = string
    cache_enabled         = optional(bool, true)
    cache_expiration_time = optional(number, 31919000) # 1 year in seconds. Ignored when permacache_storagezone is set (the provider sets it)
    cache_errors          = optional(bool, true)
    cache_vary            = optional(list(string), ["hostname", "querystring"])
    cache_chunked         = optional(bool, true)
    cors_enabled          = optional(bool, true)
    cors_extensions = optional(list(string),
      ["eot", "ttf", "woff", "woff2", "css", "js", "jpg", "jpeg", "png", "webp", "gif", "mp3", "mp4", "mpeg", "svg", "webm"]
    )
    add_canonical_header              = optional(bool, false)
    safehop_enabled                   = optional(bool, true)
    safehop_connection_timeout        = optional(number, 10)
    safehop_response_timeout          = optional(number, 60)
    safehop_retry_count               = optional(number, 2)
    safehop_retry_delay               = optional(number, 0)
    safehop_retry_reasons             = optional(list(string), ["connectionTimeout", "responseTimeout"])
    block_root_path                   = optional(bool, false)
    sort_querystring                  = optional(bool, true)
    strip_cookies                     = optional(bool, false)
    tls_level                         = optional(string, "ModernOnly")
    request_coalescing_enabled        = optional(bool, false)
    websockets_enabled                = optional(bool, false)
    websockets_max_connections        = optional(number)
    block_referers                    = optional(set(string))
    log_forward_enabled               = optional(bool, false)
    log_forward_format                = optional(string)
    log_forward_port                  = optional(number)
    log_forward_protocol              = optional(string)
    log_forward_server                = optional(string)
    log_forward_token                 = optional(string)
    log_enabled                       = optional(bool, true)
    log_anonymized                    = optional(bool, false)
    log_anonymized_style              = optional(string, "OneDigit")
    log_storage_enabled               = optional(bool, false)
    log_storage_zone                  = optional(number)
    cache_expiration_time_browser     = optional(number, -1)
    cache_stale                       = optional(set(string), [])
    cache_vary_cookie                 = optional(set(string), [])
    cache_vary_headers                = optional(set(string), [])
    cache_vary_querystring            = optional(set(string), [])
    use_background_update             = optional(bool) # Omitted by default: the provider defaults to false and sets true when cache_stale is used
    permacache_storagezone            = optional(number, 0)
    request_coalescing_timeout        = optional(number, 30)
    allow_referers                    = optional(set(string), [])
    block_ips                         = optional(set(string), [])
    block_no_referer                  = optional(bool, true)
    block_post_requests               = optional(bool, false)
    disable_letsencrypt               = optional(bool, false)
    tls_support                       = optional(set(string), [])
    errorpage_whitelabel              = optional(bool, true)
    errorpage_custom_enabled          = optional(bool, false)
    errorpage_custom_content          = optional(string)
    errorpage_statuspage_enabled      = optional(bool, false)
    errorpage_statuspage_code         = optional(string)
    limit_after                       = optional(number, 0)
    limit_bandwidth                   = optional(number, 0)
    limit_burst                       = optional(number, 0)
    limit_connections                 = optional(number, 0)
    limit_download_speed              = optional(number, 0)
    limit_requests                    = optional(number, 0)
    originshield_enabled              = optional(bool, false)
    originshield_zone                 = optional(string)
    originshield_concurrency_limit    = optional(bool, false)
    originshield_concurrency_requests = optional(number, 200)
    originshield_queue_requests       = optional(number, 5000)
    originshield_queue_wait           = optional(number, 30)
    s3_auth_enabled                   = optional(bool, false)
    s3_auth_key                       = optional(string, "")
    s3_auth_region                    = optional(string, "")
    s3_auth_secret                    = optional(string, "")
    token_auth_enabled                = optional(bool, false)
    token_auth_ip_validation          = optional(bool, false)
    origin = object({
      type                        = string #"OriginUrl"
      url                         = optional(string)
      verify_ssl                  = optional(bool, true)
      follow_redirects            = optional(bool, false)
      forward_host_header         = optional(bool, false)
      host_header                 = optional(string)
      middleware_script           = optional(number)
      script                      = optional(number)
      script_execute_before_cache = optional(bool, false)
      storagezone                 = optional(number)
      container_app_id            = optional(string)
      container_endpoint_id       = optional(string)
      dns_port                    = optional(number)
      dns_scheme                  = optional(string)
    })
    routing = object({
      tier                 = string
      zones                = optional(list(string), ["ASIA", "EU", "US", "AF"])
      blocked_countries    = optional(list(string), [])
      redirected_countries = optional(list(string), [])
      filters              = optional(set(string)) # Defaults to ["scripting"] for ComputeScript origins or when origin.middleware_script is set, otherwise ["all"]
    })
    optimizer_enabled                     = optional(bool)
    optimizer_webp                        = optional(bool)
    optimizer_dynamic_image_api           = optional(bool)
    optimizer_burrow                      = optional(bool)
    optimizer_classes_force               = optional(bool)
    optimizer_html_prerender              = optional(bool)
    optimizer_html_to_markdown            = optional(bool, false)
    optimizer_minify_css                  = optional(bool)
    optimizer_minify_js                   = optional(bool)
    optimizer_smartimage                  = optional(bool)
    optimizer_smartimage_desktop_maxwidth = optional(number)
    optimizer_smartimage_desktop_quality  = optional(number)
    optimizer_smartimage_mobile_maxwidth  = optional(number)
    optimizer_smartimage_mobile_quality   = optional(number)
    optimizer_watermark                   = optional(bool)
    optimizer_watermark_borderoffset      = optional(number)
    optimizer_watermark_minsize           = optional(number)
    optimizer_watermark_position          = optional(string)
    optimizer_watermark_url               = optional(string)
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_pullzone_access_lists"></a> [pullzone\_access\_lists](#input\_pullzone\_access\_lists)

Description:   Optional: Access lists to apply to the pull zone.  
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_access_list

Type:

```hcl
map(object({
    name    = string
    action  = string
    type    = string
    entries = set(string)
    enabled = optional(bool, true)
  }))
```

Default: `{}`

### <a name="input_pullzone_edge_rules"></a> [pullzone\_edge\_rules](#input\_pullzone\_edge\_rules)

Description:   Optional: Additional pullzone edge rules to apply.  
  Priority is an integer value that determines the order of the rules, starting at 1.  
  The specified priority will be used to order the additional rules relative to each other.  
  Rules will be added after the default rules.

Type:

```hcl
map(object({
    description = string
    enabled     = optional(bool, true)
    priority    = number
    actions = list(object({
      type       = string
      parameter1 = optional(string)
      parameter2 = optional(string)
      parameter3 = optional(string)
    }))
    match_type = string
    triggers = list(object({
      type       = string
      match_type = string
      patterns   = list(string)
      parameter1 = optional(string)
      parameter2 = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_pullzone_hostnames"></a> [pullzone\_hostnames](#input\_pullzone\_hostnames)

Description: Optional: Map of hostnames and their configuration to be used for the pull zone.

Type:

```hcl
map(object({
    pullzone        = optional(number)
    name            = string
    tls_enabled     = optional(bool, true)
    force_ssl       = optional(bool, true)
    certificate     = optional(string)
    certificate_key = optional(string)
  }))
```

Default: `{}`

### <a name="input_pullzone_shield_config"></a> [pullzone\_shield\_config](#input\_pullzone\_shield\_config)

Description:   Configuration for the pull zone shield, defaults will be used for values not supplied.  
  Required when pullzone\_shield\_enabled is true (the default); ignored when it is false.  
  For valid values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_shield

  Note: ddos mode will be ignored as Bunny has removed this option from the API, and it is now always set to "Block".

Type:

```hcl
object({
    tier                      = optional(string, "Basic")
    whitelabel                = optional(bool, true)
    whitelabel_block          = optional(string)
    whitelabel_challenge      = optional(string)
    whitelabel_rate_limit     = optional(string)
    upload_scanning_antivirus = optional(string)
    upload_scanning_csam      = optional(string)
    ddos = object({
      level            = optional(string, "Low")
      challenge_window = optional(number, 3600)
      mode             = optional(string, "Block") # Unused and no longer supported by API, kept for module compatibility
    })
    waf = object({
      enabled                       = optional(bool, false)
      allowed_http_methods          = optional(list(string))
      allowed_http_versions         = optional(list(string), ["HTTP/2", "HTTP/2.0"])
      allowed_request_content_types = optional(list(string))
      blocking_sensitivity          = optional(number)
      body_limit_request            = optional(string)
      body_limit_response           = optional(string)
      detection_sensitivity         = optional(number)
      execution_sensitivity         = optional(number)
      log_headers                   = optional(bool)
      log_headers_excluded          = optional(list(string))
      mode                          = string
      realtime_threat_intelligence  = optional(bool, true)
      rules_disabled                = optional(list(string))
      rules_logonly                 = optional(list(string))
    })
    bot_detection = object({
      complex_fingerprinting  = optional(bool)
      fingerprint_aggression  = optional(number)
      fingerprint_sensitivity = optional(number)
      ip_sensitivity          = optional(number)
      mode                    = string
      request_integrity       = optional(number)
    })
    bot_categorization = optional(list(object({
      category = string
      action   = string
      overrides = optional(list(object({
        bot    = string
        action = string
      })))
    })))
    access_list = optional(set(object({
      action = string
      id     = number
    })), [])
  })
```

Default: `null`

### <a name="input_pullzone_shield_enabled"></a> [pullzone\_shield\_enabled](#input\_pullzone\_shield\_enabled)

Description:   Optional: Whether to create a Bunny Shield zone for the pull zone.  
  When false, pullzone\_shield\_config, pullzone\_shield\_waf\_rules, pullzone\_shield\_rate\_limit\_rules and  
  pullzone\_access\_lists are ignored.

Type: `bool`

Default: `true`

### <a name="input_pullzone_shield_rate_limit_rules"></a> [pullzone\_shield\_rate\_limit\_rules](#input\_pullzone\_shield\_rate\_limit\_rules)

Description:   Optional: Pull zone shield rate limit rules to apply.  
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_ratelimit_rule

Type:

```hcl
map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator             = string
      value                = string
      variable             = string
      variable_value       = optional(string)
      variable_value_regex = optional(bool, false)
      negated              = optional(bool, false)
    }))
    limit = object({
      requests    = number
      interval    = optional(number, 1)
      counter_key = optional(string, "IP")
    })
    response = object({
      interval = optional(number, 60)
      action   = optional(string, "RateLimit")
    })
  }))
```

Default: `{}`

### <a name="input_pullzone_shield_waf_rules"></a> [pullzone\_shield\_waf\_rules](#input\_pullzone\_shield\_waf\_rules)

Description:   Optional: Pull zone shield waf rules to apply.  
  For valid property values, refer to https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs/resources/pullzone_waf_rule

Type:

```hcl
map(object({
    name            = string
    description     = string
    transformations = optional(list(string))
    condition = map(object({
      operator             = string
      value                = string
      variable             = string
      variable_value       = optional(string)
      variable_value_regex = optional(bool, false)
      negated              = optional(bool, false)
    }))
    response = object({
      action = string
    })
  }))
```

Default: `{}`

### <a name="input_x_azure_fdid_value"></a> [x\_azure\_fdid\_value](#input\_x\_azure\_fdid\_value)

Description: Optional: Value for the X-Azure-FDID header. If not set, a X-Azure-FDID header will not be sent to the origin.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_pullzone"></a> [pullzone](#output\_pullzone)

Description: n/a

### <a name="output_pullzone_default_hostname"></a> [pullzone\_default\_hostname](#output\_pullzone\_default\_hostname)

Description: n/a

### <a name="output_pullzone_name"></a> [pullzone\_name](#output\_pullzone\_name)

Description: n/a

## Modules

No modules.

# Additional Information

This module is created for use at Ubiq.
<!-- END_TF_DOCS -->