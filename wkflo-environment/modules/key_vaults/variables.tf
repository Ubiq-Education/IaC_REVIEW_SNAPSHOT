variable "azurerm_client_config_current_tenant_id" {
  type        = string
  description = "The tenant ID of the current AzureRM client configuration."
}

variable "kv_name" {
  type        = string
  description = "The name of the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Key Vault."
}

variable "az_long_region" {
  type        = string
  description = "The Azure region where the Key Vault will be deployed."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the Key Vault."
}

variable "kv_secret_user_principal_ids" {
  type        = map(string)
  default     = {}
  description = "A list of principal IDs to assign the Key Vault Secrets User role."
}

variable "kv_certificate_user_principal_ids" {
  type        = map(string)
  default     = {}
  description = "A list of principal IDs to assign the Key Vault Certificate User role."
}

variable "kv_crypto_service_encryption_user_principal_ids" {
  type        = map(string)
  default     = {}
  description = "A list of principal IDs to assign the Key Vault Crypto Service Encryption User role."
}

variable "key_names" {
  type        = map(string)
  default     = {}
  description = "A list of key names to create in the Key Vault."
}

variable "network_acls_default_action" {
  type        = string
  default     = "Deny"
  description = "The default action for the Key Vault network ACLs."
}

variable "network_acls_virtual_network_subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of virtual network subnet IDs to allow access to the Key Vault."
}
