resource "azurerm_key_vault_key" "main" {
  for_each = var.key_names

  name            = each.value
  key_vault_id    = module.avm-res-keyvault-vault.resource_id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["unwrapKey", "wrapKey"]
  expiration_date = "1982-12-31T00:00:00Z"
  tags            = var.tags

  rotation_policy {
    expire_after         = "P1Y"
    notify_before_expiry = "P28D"
    automatic {
      time_before_expiry = "P30D"
    }
  }

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "time_sleep" "keys" {
  create_duration = "30s"

  triggers = {
    keys = join(",", [for k in azurerm_key_vault_key.main : k.id])
  }
}

# Wait for initial rotation and get new ids for output
data "azurerm_key_vault_key" "main" {
  for_each = var.key_names

  name         = each.value
  key_vault_id = module.avm-res-keyvault-vault.resource_id

  depends_on = [time_sleep.keys]
}
