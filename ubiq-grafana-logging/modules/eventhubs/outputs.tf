output "azurerm_eventhub_namespace" {
  value     = azurerm_eventhub_namespace.main
  sensitive = true
}

output "azurerm_eventhub_namespace_authorization_rule_send" {
  value     = azurerm_eventhub_namespace_authorization_rule.send
  sensitive = true
}
