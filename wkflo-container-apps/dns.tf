resource "azurerm_dns_cname_record" "main" {
  for_each = var.bunny_hostnames

  provider = azurerm.shared
  # strip ".amais.com" or ".wkflo.ai" from the end of the hostname to get the record name
  name                = replace(each.value, endswith(each.value, ".amais.com") ? ".amais.com" : ".wkflo.ai", "")
  zone_name           = data.azurerm_dns_zone.main[each.key].name
  resource_group_name = data.azurerm_dns_zone.main[each.key].resource_group_name
  ttl                 = 3600
  record              = "${local.bunny_pullzone_name}.${module.bunny_cdn_waf[0].pullzone.cdn_domain}"
  tags                = local.tags
}

resource "time_sleep" "cdn_dns" {
  count = length(var.bunny_hostnames) > 0 ? 1 : 0

  create_duration = "300s"

  triggers = {
    for k, v in azurerm_dns_cname_record.main : k => v.id
  }
}
