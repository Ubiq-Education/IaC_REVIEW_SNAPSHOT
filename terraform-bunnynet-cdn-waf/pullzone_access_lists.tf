resource "bunnynet_pullzone_access_list" "main" {
  for_each = var.pullzone_shield_enabled && local.shield_tier != "Basic" ? var.pullzone_access_lists : {}

  pullzone = bunnynet_pullzone.main.id
  name     = each.value.name
  action   = each.value.action
  type     = each.value.type
  entries  = each.value.entries
  enabled  = each.value.enabled

  # Shield API needs propagation time after creation before shield-scoped resources are queryable
  depends_on = [time_sleep.bunnynet_pullzone_shield]
}
