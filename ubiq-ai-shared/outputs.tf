output "ais_urls" {
  value = { for k in keys(module.amais-ai) : k => module.amais-ai[k].azure_openai_client_url }
}

output "bunny_fqdn" {
  value = module.bunny_cdn_waf.pullzone_default_hostname
}
