variable "network_resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  description = "List of all network resource groups. Designed for the output of the ubiq-networking stack."
}
