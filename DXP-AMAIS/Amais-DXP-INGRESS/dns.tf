resource "azurerm_dns_cname_record" "ingress_main" {
  name                = local.dns_alias_name
  zone_name           = local.dns_alias_zone_name
  resource_group_name = "rg-uks-ubiq-networking"
  ttl                 = 3600
  record              = "${local.bunny_pullzone_name}.${module.bunny_cdn_waf.pullzone.cdn_domain}"
  tags                = local.common_tags
}

resource "azurerm_dns_cname_record" "ingress_staging" {
  name                = local.dns_alias_staging_name
  zone_name           = local.dns_alias_zone_name
  resource_group_name = "rg-uks-ubiq-networking"
  ttl                 = 3600
  record              = "${local.bunny_pullzone_name}.${module.bunny_cdn_waf.pullzone.cdn_domain}"
  tags                = local.common_tags
}

resource "time_sleep" "dns" {
  create_duration = "300s"

  triggers = {
    dns_ingress_main_fqdn    = azurerm_dns_cname_record.ingress_main.fqdn
    dns_ingress_staging_fqdn = azurerm_dns_cname_record.ingress_staging.fqdn
  }
}
