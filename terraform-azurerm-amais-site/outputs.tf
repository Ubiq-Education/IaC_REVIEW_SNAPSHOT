output "resource_group_id" {
  value = azurerm_resource_group.main.id
}

output "website_prod_url" {
  value = (var.bunny_cdn_enablement == "yes" ?
    "https://${trimsuffix(azurerm_dns_cname_record.cdn_root[0].fqdn, ".")}" :
    "https://${local.web_app_default_hostname}"
  )
}

output "website_staging_url" {
  value = local.add_staging_slot ? (
    var.bunny_cdn_enablement == "yes" ?
    "https://${trimsuffix(azurerm_dns_cname_record.cdn_staging[0].fqdn, ".")}" :
    "https://${local.web_app_staging_default_hostnames[0]}"
  ) : "none"
}

output "bunny_pullzone_id" {
  value = var.bunny_cdn_enablement == "yes" ? module.bunny_cdn_waf[0].pullzone.id : null
}

output "ubiq_sso_entity_id" {
  value = local.ubiq_sso_entity_id
}

output "ubiq_sso_urls" {
  value = local.ubiq_sso_app_urls
}

output "ubiq_sso_redirect_urls" {
  value = [for url in local.ubiq_sso_app_urls : "${replace(url, "/$", "")}/web/account/saml/${local.ubiq_sso_entity_id}"]
}
