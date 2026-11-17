output "uri" {
  value       = trimsuffix(module.avm-res-keyvault-vault.uri, "/")
  description = "The URI of the key vault with no trailing slash."
}

output "id" {
  value       = module.avm-res-keyvault-vault.resource_id
  description = "The ID of the key vault for the uksouth region."
}

output "keys" {
  value = data.azurerm_key_vault_key.main
}
