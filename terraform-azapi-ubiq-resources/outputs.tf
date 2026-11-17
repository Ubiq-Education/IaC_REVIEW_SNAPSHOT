output "all_vnets" {

  value = local.all_vnets != null ? {
    for vnet in local.all_vnets : vnet.name => {
      id            = vnet.id
      location      = vnet.location
      address_space = vnet.properties.addressSpace.addressPrefixes
      flow_logs     = vnet.properties.flowLogs
      subnets = [
        for sub in vnet.properties.subnets : {
          name           = sub.name
          id             = sub.id
          address_prefix = sub.properties.addressPrefix
        }
      ]
    }
  } : {}
}

output "hub_vnets" {
  value = local.hub_vnets != null ? {
    for vnet in local.hub_vnets : vnet.name => {
      id            = vnet.id
      location      = vnet.location
      address_space = vnet.properties.addressSpace.addressPrefixes
      flow_logs     = vnet.properties.flowLogs
      subnets = [
        for sub in vnet.properties.subnets : {
          name           = sub.name
          id             = sub.id
          address_prefix = sub.properties.addressPrefix
        }
      ]
    }
  } : {}
}

output "twingate_subnets" {
  value = local.twingate_subnets
}

output "terraform_subnets" {
  value = local.terraform_subnets
}

output "devops_subnets" {
  value = local.devops_subnets
}

output "secure_access_gw_pips" {
  value = local.secure_access_gw_pips
}

output "pum" {
  value = local.pum_api
}

output "google_user_triggered_fetcher_ips" {
  value = local.google_user_triggered_fetcher_ips
}
