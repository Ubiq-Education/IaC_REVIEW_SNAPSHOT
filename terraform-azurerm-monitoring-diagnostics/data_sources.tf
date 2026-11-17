data "azurerm_storage_account" "sql_auditing" {
  # This count condition matches the validation condition for sql_advanced_auditing_storage_account.storage_account_id
  count = length(local.sql_auditing_sa) > 0 ? 1 : 0

  name                = local.sql_auditing_sa.id["resource_name"]
  resource_group_name = local.sql_auditing_sa.id["resource_group_name"]
}
