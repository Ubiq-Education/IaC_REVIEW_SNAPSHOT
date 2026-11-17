variable "az_long_region" {
  type        = string
  description = "Azure long region name"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group in which to deploy resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

variable "vnet_configurations" {
  type = map(object({
    nat_gateway                        = optional(bool, false)
    nat_gateway_pip_count              = optional(number, 1)
    nat_gateway_used_for_secure_access = optional(bool, false)
    role_assignments = optional(map(object({
      role_names = list(string)
    })), {})
    address_space = list(string)
    subnets = map(object({
      address_prefixes        = list(string)
      associate_nat_gateway   = optional(bool, false)
      service_delegation_name = optional(string, null)
      service_endpoints       = optional(list(string), [])
    }))
  }))
  description = <<DESCRIPTION
  Map of virtual network configurations. The key is the name of the virtual network and the value is a map of configuration options.

  For role assignments the principal id is the guid required by the role assingment resource, for SPNs this is the Entra object id.

  The "Microsoft.Storage.Global" service endpoint is automatically added to all subnets. To add additional service endpoints, specify them in the "service_endpoints" list.

  ```terraform
  vnet_configurations = {
    "vnet1" = {
      nat_gateway                        = true
      nat_gateway_pip_count              = 1
      nat_gateway_used_for_secure_access = true
      role_assignments = {
        # Assign the "Reader" role to the identity specified by the principal id
        "00000000-0000-0000-0000-000000000000" = {
          role_names = ["Reader"]
        }
      }
      address_space                      = ["1.2.3.4/21"]
      subnets = {
        "subnet1" = {
          address_prefixes        = ["1.2.3.4/24"]
          associate_nat_gateway   = true
          service_delegation_name = "Microsoft.ContainerInstance/containerGroups"
          service_endpoints       = ["Microsoft.Storage"]
          }
        }
      }
    }
  ```
  DESCRIPTION

  validation {
    condition = alltrue(flatten([
      for vnet in values(var.vnet_configurations) : [
        for cidr in vnet.address_space : can(cidrhost(cidr, 0))
      ]
    ]))
    error_message = "VNET address spaces must be in CIDR notation"
  }

  validation {
    condition = alltrue(flatten([
      for vnet in values(var.vnet_configurations) : [
        for subnet in values(vnet.subnets) : [
          for cidr in subnet.address_prefixes : can(cidrhost(cidr, 0))
        ]
      ]
    ]))
    error_message = "Subnet address_prefix must be in CIDR notation"
  }

  validation {
    condition = alltrue([
      for vnet in values(var.vnet_configurations) : alltrue([
        for subnet_name in keys(vnet.subnets) : !contains(split("", subnet_name), ":")
      ])
    ])
    error_message = "Subnet names must not contain the ':' character."
  }

  validation {
    condition = alltrue([
      for vnet in values(var.vnet_configurations) : alltrue([
        for subnet in values(vnet.subnets) : length(subnet.address_prefixes) == 1
      ])
    ])
    error_message = "Each subnet must have exactly one item in address_prefixes."
  }
}
