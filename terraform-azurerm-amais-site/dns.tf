## Static assets CDN CNAME - points to Bunny when enabled

resource "azurerm_dns_cname_record" "cdn_ams" {
  provider            = azurerm.shared
  name                = local.lower_site_name
  zone_name           = data.azurerm_dns_zone.static_amais_com.name
  resource_group_name = data.azurerm_dns_zone.static_amais_com.resource_group_name
  ttl                 = 3600
  record              = var.bunny_cdn_enablement == "yes" ? "${local.bunny_pullzone_name}.${module.bunny_cdn_waf[0].pullzone.cdn_domain}" : module.avm-res-storage-storageaccount.resource.primary_web_host
  tags                = merge(var.tags, local.common_tags)
}

## AMAIS alias for production slot using Bunny CDN/WAF
resource "azurerm_dns_cname_record" "cdn_root" {
  count               = var.bunny_cdn_enablement == "yes" ? 1 : 0
  provider            = azurerm.shared
  name                = local.lower_site_name
  zone_name           = data.azurerm_dns_zone.website_amais_com.name
  resource_group_name = data.azurerm_dns_zone.website_amais_com.resource_group_name
  ttl                 = 3600
  record              = "${local.bunny_pullzone_name}.${module.bunny_cdn_waf[0].pullzone.cdn_domain}"
  tags                = merge(var.tags, local.common_tags)
}

## Alias for root cdn subpath if not all primary website traffic to Bunny CDN/WAF
resource "azurerm_dns_cname_record" "cdn_root_subpath" {
  count               = var.bunny_cdn_enablement == "yes" && !var.web_app_x_azure_fdid_lockdown ? 1 : 0
  provider            = azurerm.shared
  name                = local.root_cdn_path_name
  zone_name           = data.azurerm_dns_zone.website_amais_com.name
  resource_group_name = data.azurerm_dns_zone.website_amais_com.resource_group_name
  ttl                 = 3600
  record              = "${local.bunny_pullzone_name}.${module.bunny_cdn_waf[0].pullzone.cdn_domain}"
  tags                = merge(var.tags, local.common_tags)
}

## AMAIS alias for staging slot using Bunny CDN/WAF
resource "azurerm_dns_cname_record" "cdn_staging" {
  count               = var.bunny_cdn_enablement == "yes" && local.add_staging_slot ? 1 : 0
  provider            = azurerm.shared
  name                = "${local.lower_site_name}-${local.staging_slot_name}"
  zone_name           = data.azurerm_dns_zone.website_amais_com.name
  resource_group_name = data.azurerm_dns_zone.website_amais_com.resource_group_name
  ttl                 = 3600
  record              = "${local.bunny_pullzone_name}.${module.bunny_cdn_waf[0].pullzone.cdn_domain}"
  tags                = merge(var.tags, local.common_tags)
}

resource "time_sleep" "cdn_dns_ams" {
  create_duration = "60s"

  triggers = {
    dns_cdn_ams_fqdn = azurerm_dns_cname_record.cdn_ams.fqdn
  }
}


resource "time_sleep" "cdn_dns" {
  create_duration = "300s"

  triggers = {
    dns_cdn_root_fqdn         = var.bunny_cdn_enablement == "yes" ? azurerm_dns_cname_record.cdn_root[0].fqdn : "none"
    dns_cdn_root_subpath_fqdn = var.bunny_cdn_enablement == "yes" && !var.web_app_x_azure_fdid_lockdown ? azurerm_dns_cname_record.cdn_root_subpath[0].fqdn : "none"
    dns_cdn_staging_fqdn      = var.bunny_cdn_enablement == "yes" && local.add_staging_slot ? azurerm_dns_cname_record.cdn_staging[0].fqdn : "none"
  }
}
