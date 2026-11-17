resource "bunnynet_pullzone_hostname" "main" {
  pullzone    = bunnynet_pullzone.main.id
  name        = local.pullzone_default_hostname
  tls_enabled = true
  force_ssl   = true
}

resource "bunnynet_pullzone_hostname" "custom" {
  for_each = var.pullzone_hostnames

  pullzone        = each.value.pullzone != null ? each.value.pullzone : bunnynet_pullzone.main.id
  name            = each.value.name
  tls_enabled     = each.value.tls_enabled
  force_ssl       = each.value.force_ssl
  certificate     = each.value.certificate
  certificate_key = each.value.certificate_key
}
