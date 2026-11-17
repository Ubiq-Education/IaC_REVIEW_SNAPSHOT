variable "sub_id" {
  type        = string
  description = "The Azure subscription ID."
}

variable "primary_region" {
  type        = string
  description = "The primary region for the deployment, used for shared resources."

  validation {
    error_message = "The value of the name attribute must match a value in var.regions"
    condition     = contains(var.regions, var.primary_region)
  }
}

variable "regions" {
  type        = list(string)
  description = "The list of regions in which to deploy this AI Services configuration."
}

variable "deployment_name" {
  type        = string
  description = "The name of the deployment."

  validation {
    error_message = "value must end with '-primary' or '-secondary'"
    condition     = can(regex(".*-(primary|secondary)$", var.deployment_name))
  }
}

variable "bunny_pz_middleware_script_id" {
  type        = number
  default     = null
  description = "The ID of the Bunny CDN middleware script to use for the pullzone. If null, no script will be applied."
}

variable "cognitive_deployments" {
  type = map(object({
    name                  = string
    format                = optional(string, "OpenAI")
    version               = optional(string)
    sku_name              = optional(string, "GlobalStandard")
    capacity_in_thousands = number
    regions               = optional(list(string))
  }))
  description = "List of cognitive deployments to create"

  validation {
    error_message = "Any cognitive deployment regions must also be present in var.regions"
    condition = alltrue([
      for deployment in values(var.cognitive_deployments) : deployment.regions == null ? true : alltrue([
        for region in deployment.regions : contains(var.regions, region)
      ])
    ])
  }
}


variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource"
}

variable "pullzone_zones" {
  type        = list(string)
  description = "List of zones for the pullzone routing configuration."
}

variable "syslog_token" {
  type        = string
  sensitive   = true
  default     = null
  description = "Syslog token to use for log forwarding to global receivers"
}
