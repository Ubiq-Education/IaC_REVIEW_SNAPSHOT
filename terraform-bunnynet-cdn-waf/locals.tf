locals {
  pullzone_name             = lower(var.pullzone_config.name)
  pullzone_default_hostname = "${local.pullzone_name}.${bunnynet_pullzone.main.cdn_domain}"
  # try() keeps these safe when pullzone_shield_config is null (shield disabled)
  shield_tier               = try(var.pullzone_shield_config.tier, "Basic")
  shield_bot_categorization = try(var.pullzone_shield_config.bot_categorization, null)
  bot_categorization_ordered = (local.shield_bot_categorization != null ? [
    for category in sort(local.shield_bot_categorization[*].category) :
    one([
      for item in local.shield_bot_categorization :
      item
      if item.category == category
    ])
  ] : [])
}
