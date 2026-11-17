variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID to deploy the resources to"
}

variable "az_long_region" {
  type        = string
  description = "The Azure region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy the resources to"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to the resources"
}

variable "network_acl_default_action" {
  type        = string
  default     = "Deny"
  description = "The default action for the network ACLs"
}

variable "network_acl_subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to allow access to the Key Vault"
}
