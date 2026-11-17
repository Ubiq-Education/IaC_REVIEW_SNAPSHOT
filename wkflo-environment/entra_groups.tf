# Entra group to be assigned SQL DB permissions by DevOps pipeline
# App identities will be added to group by wkflo-container-apps TF config
resource "azuread_group" "amais_sql_rw" {
  for_each = var.regions_enabled

  display_name     = "${local.cae_names[each.key]}-SQL-RBAC-RW"
  description      = "Group for SQL RBAC RW permissions for ${local.cae_names[each.key]}"
  security_enabled = true
}
