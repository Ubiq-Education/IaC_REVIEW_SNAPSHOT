resource "random_id" "traffic_manager" {
  count = try(var.traffic_manager_endpoint.add_endpoint, false) ? 1 : 0

  byte_length = 8
  keepers = {
    # Add a keeper to ensure consistent recreation
    profile_id = var.traffic_manager_endpoint.profile_id
  }
}

resource "azurerm_traffic_manager_external_endpoint" "main" {
  count = try(var.traffic_manager_endpoint.add_endpoint, false) ? 1 : 0

  name = (
    var.traffic_manager_endpoint.name != null ?
    var.traffic_manager_endpoint.name :
    "${var.name}-${random_id.traffic_manager[0].hex}"
  )
  profile_id           = var.traffic_manager_endpoint.profile_id
  enabled              = var.traffic_manager_endpoint.enabled
  always_serve_enabled = var.traffic_manager_endpoint.always_serve_enabled
  weight               = var.traffic_manager_endpoint.weight
  endpoint_location = (
    var.traffic_manager_endpoint.endpoint_location != null ?
    var.traffic_manager_endpoint.endpoint_location :
    var.cae_location
  )
  target = (
    var.traffic_manager_endpoint.target != null ?
    var.traffic_manager_endpoint.target :
    "${module.container_app.container_app.name}.${var.cae_default_domain}"
  )
}
