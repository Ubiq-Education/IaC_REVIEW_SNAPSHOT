output "cae" {
  value = {
    for region, _ in var.regions_enabled : region => {
      resource = {
        id                = module.avm-res-app-managedenvironment[region].id
        name              = module.avm-res-app-managedenvironment[region].name
        default_domain    = module.avm-res-app-managedenvironment[region].default_domain
        custom_domain     = "${local.cae_names[region]}.${local.domain_suffix}"
        static_ip_address = module.avm-res-app-managedenvironment[region].static_ip_address
      }
      subnet_id = module.regional_network[region].subnets["wkflo-01:cae-01"].id
      identities = {
        principal_id = module.avm-res-managedidentity-userassignedidentity-cae[region].principal_id
        resource_id  = module.avm-res-managedidentity-userassignedidentity-cae[region].resource_id
        client_id    = module.avm-res-managedidentity-userassignedidentity-cae[region].client_id
      }
      arcpull_identity = {
        principal_id = module.avm-res-managedidentity-userassignedidentity-global-arcpull.principal_id
        resource_id  = module.avm-res-managedidentity-userassignedidentity-global-arcpull.resource_id
        client_id    = module.avm-res-managedidentity-userassignedidentity-global-arcpull.client_id
      }
      redis_resources = {
        id          = azurerm_managed_redis.main[region].id
        host        = azurerm_managed_redis.main[region].hostname
        database_id = try(azurerm_managed_redis.main[region].default_database[0].id, "")
        endpoint    = "${azurerm_managed_redis.main[region].hostname}:${try(azurerm_managed_redis.main[region].default_database[0].port, "db_port_not_found")}"
      }
      mssql_resources = {
        for db_key, db in azurerm_mssql_database.main : replace(db_key, "${region}-", "") => {
          name      = db.name
          id        = db.id
          server_id = db.server_id
        } if local.region_sqldb_map[db_key].region == region
      }
      postgresql_resources = {
        name = azurerm_postgresql_flexible_server.main[region].name
        id   = azurerm_postgresql_flexible_server.main[region].id
        fqdn = azurerm_postgresql_flexible_server.main[region].fqdn
      }
      key_vault_resources = {
        id  = module.key_vault[region].id
        uri = module.key_vault[region].uri
      }
      law_resources = {
        id = azurerm_log_analytics_workspace.main[region].id
      }
      resource_group_name        = azurerm_resource_group.main[region].name
      app_resource_group_name    = azurerm_resource_group.apps[region].name
      global_resource_group_name = azurerm_resource_group.shared.name
      storage_accounts = {
        name = module.avm-res-storage-storageaccount[region].name
        id   = module.avm-res-storage-storageaccount[region].resource_id
      }
      signalr_resources = {
        id          = azurerm_signalr_service.main[region].id
        hostname    = azurerm_signalr_service.main[region].hostname
        public_port = azurerm_signalr_service.main[region].public_port
        server_port = azurerm_signalr_service.main[region].server_port
        custom_fqdn = local.sigr_custom_domain_and_cert_enabled[region] ? azurerm_dns_cname_record.signalr_custom_domain[region].fqdn : "none"
      }
    }
  }
}

output "entra_app" {
  value = {
    client_id = azuread_application.main.client_id
    object_id = azuread_application.main.object_id
  }
}
